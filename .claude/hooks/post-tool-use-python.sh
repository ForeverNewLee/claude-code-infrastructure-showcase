#!/usr/bin/env bash
# post-tool-use-python.sh
# PostToolUse hook: runs after Claude edits a .py file
# - Runs ruff format + ruff check --fix automatically
# - Logs affected files for end-of-session mypy + pytest suggestion
#
# Install: Add to .claude/settings.json PostToolUse hooks
# Requires: uv (https://docs.astral.sh/uv/)

set -euo pipefail

# ── Read input ─────────────────────────────────────────────────────────────────
tool_info=$(cat)

tool_name=$(echo "$tool_info" | jq -r '.tool_name // empty')
file_path=$(echo "$tool_info" | jq -r '.tool_input.file_path // empty')
session_id=$(echo "$tool_info" | jq -r '.session_id // empty')

# ── Guard: only process Edit/MultiEdit/Write on .py files ──────────────────────
if [[ ! "$tool_name" =~ ^(Edit|MultiEdit|Write)$ ]]; then
    exit 0
fi

if [[ -z "$file_path" ]] || [[ ! "$file_path" =~ \.py$ ]]; then
    exit 0
fi

# Skip test files from auto-format notification (still format them, just no noise)
is_test=false
if [[ "$file_path" =~ (test_|_test\.py|/tests/) ]]; then
    is_test=true
fi

# ── Track affected files ────────────────────────────────────────────────────────
cache_dir="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/py-cache/${session_id:-default}"
mkdir -p "$cache_dir"
echo "$file_path" >> "$cache_dir/edited-files.log"

# ── Detect project root (where pyproject.toml lives) ──────────────────────────
project_root="${CLAUDE_PROJECT_DIR:-$PWD}"

# Walk up from file_path to find pyproject.toml
dir="$(dirname "$file_path")"
while [[ "$dir" != "/" && "$dir" != "$project_root" ]]; do
    if [[ -f "$dir/pyproject.toml" ]]; then
        project_root="$dir"
        break
    fi
    dir="$(dirname "$dir")"
done

# ── Check ruff availability via uv (preferred) or global fallback ─────────────
if command -v uv &>/dev/null; then
    # ✅ Always prefer uv run: uses project venv's ruff, not a random global one
    RUFF="uv run ruff"
elif command -v ruff &>/dev/null; then
    # ⚠️  Fallback: global ruff (version may differ from pyproject.toml)
    RUFF="ruff"
else
    echo "⚠️  uv not found. Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
    exit 0  # Don't block, just warn
fi

# ── Run ruff format ────────────────────────────────────────────────────────────
format_output=$($RUFF format "$file_path" 2>&1) || true

# ── Run ruff check --fix ───────────────────────────────────────────────────────
lint_output=$($RUFF check "$file_path" --fix 2>&1) || lint_exit=$?

# ── Output summary ─────────────────────────────────────────────────────────────
if [[ "$is_test" == "false" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🐍 PYTHON QUALITY AUTO-CHECK"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 File: $(basename "$file_path")"

    # Format result
    if echo "$format_output" | grep -q "reformatted"; then
        echo "✅ ruff format: reformatted"
    else
        echo "✅ ruff format: already clean"
    fi

    # Lint result
    if [[ "${lint_exit:-0}" -eq 0 ]]; then
        if echo "$lint_output" | grep -q "Fixed"; then
            fixed_count=$(echo "$lint_output" | grep -oE '[0-9]+ fix' | head -1)
            echo "✅ ruff check: auto-fixed ($fixed_count)"
        else
            echo "✅ ruff check: no issues"
        fi
    else
        echo "⚠️  ruff check: issues remain (run manually)"
        echo "$lint_output" | head -5
    fi

    echo ""
    echo "💡 质量馈 全部运行："
    echo "   uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0
