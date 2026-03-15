# Verify Python App

## Description

一键验证 Python 项目质量的 Agent。按顺序执行完整质量链：
`ruff format → ruff check → mypy → pytest`

实现 `added.md` 中的"编译链保障"最佳实践：编译/lint/test 必须全部过，一个都不能跳过。

> ⚠️ 所有命令通过 `uv run` 执行。项目必须有 `pyproject.toml` 且已运行过 `uv sync`。

---

## Instructions

当用户请求验证或运行质量检查时，**首先确认环境就绪**：

```bash
# 确认 pyproject.toml 存在
ls pyproject.toml
# 如果 .venv 不存在或刚更新了依赖，先同步
uv sync
```

然后按以下顺序执行：

### Step 1: ruff format（格式化）

```bash
uv run ruff format .
```

**如果失败：** 报告哪些文件被格式化了，继续下一步（format 失败很少见）。

### Step 2: ruff check（Lint）

```bash
uv run ruff check . --fix
```

**如果有错误：** 显示具体错误，分析是否已自动修复，如有剩余错误（无法自动修复的），停止并报告，请用户手动修复后再继续。

### Step 3: mypy（类型检查）

```bash
uv run mypy .
```

**如果有错误：** 显示错误详情，分析错误原因，提供修复建议。**在 mypy 通过前不运行测试**。

### Step 4: pytest（运行测试）

```bash
uv run pytest --tb=short -q
```

如需覆盖率报告：
```bash
uv run pytest --cov=src --cov-report=term-missing -q
```

**如果测试失败：** 显示失败的测试，分析失败原因（是代码问题还是测试问题），提供修复方向。

---

## Output Format

每步结束后输出状态：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐍 Python Quality Check Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: ruff format  ✅ PASSED (3 files reformatted)
Step 2: ruff check   ✅ PASSED (auto-fixed 2 issues)
Step 3: mypy         ❌ FAILED

mypy errors:
  src/myapp/service.py:42: error: Argument 1 to "get_user" has incompatible type "str"; expected "int"

Please fix mypy errors before running tests.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Common Issues and Fixes

### ruff check: import errors

```bash
# 如果 ruff 找不到本地模块
# 确保 venv 已同步（会以 editable 模式安装项目）
uv sync
```

### mypy: missing stubs

```bash
# 安装类型存根
uv add --dev types-requests types-PyYAML
# 或配置 ignore_missing_imports = true
```

### pytest: module not found

```bash
# 确保 venv 已同步（src layout 下会自动 editable install 项目）
uv sync
```

---

## Quick Commands Reference

```bash
# 单独运行各步骤
uv run ruff format .                                    # 格式化
uv run ruff check . --fix                               # Lint + 自动修复
uv run ruff check . --fix --unsafe-fixes               # 包含不安全的自动修复
uv run mypy .                                           # 类型检查
uv run mypy . --ignore-missing-imports                 # 忽略缺失的 stubs
uv run pytest -v                                        # 详细测试输出
uv run pytest -k "test_user"                            # 只运行匹配的测试
uv run pytest --lf                                      # 只运行上次失败的测试
uv run pytest --cov=src --cov-report=html              # HTML 覆盖率报告
```
