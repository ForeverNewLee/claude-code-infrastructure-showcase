# UV 环境初始化/同步

一键检测并配置 Python 项目的 UV 环境，默认 **dev 模式**（用户明确说 prod/生产时才用 `--no-dev`）。

## Instructions

### Step 1: 检测项目状态

```bash
# 检查 uv 是否安装
uv --version

# 检查 pyproject.toml 是否存在
ls pyproject.toml
```

**根据结果决策：**

| 状态 | 行动 |
|------|------|
| `uv` 未安装 | 停止，提示安装：`curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `pyproject.toml` 不存在 | 询问用户是否初始化（`uv init .`），或提示切换到正确目录 |
| `uv.lock` 不存在 | 首次同步，正常继续 |
| 一切就绪，用户没指定参数 | 按 dev 模式同步 |

---

### Step 2: 安装/同步依赖

**判断使用哪种模式：**
- 用户请求里有 `prod`/`production`/`生产` 等关键词 → Prod 模式
- 其他所有情况（包括没有指定）→ **Dev 模式（默认）**

```bash
# Dev 模式（默认：uv sync 本身就包含 dev dependencies）
uv sync

# Prod 模式（用户明确要求 prod/生产环境时）
uv sync --no-dev
```

---

### Step 3: 验证环境

```bash
# 确认 Python 版本
uv run python --version

# 查看依赖树
uv tree --depth 1
```

对于 dev 模式，额外验证工具可用：
```bash
uv run ruff --version
uv run mypy --version
uv run pytest --version
```

---

### Step 4: 输出状态摘要

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐍 UV 环境就绪
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
模式:    dev（含开发依赖）
Python:  3.11.x

✅ 依赖已同步
✅ ruff / mypy / pytest 可用

下一步：
  运行测试:    uv run pytest
  质量检查:    uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest
  提交代码:    /commit-push-pr
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 常见场景

### 新克隆仓库（dev 模式）
```bash
git clone <repo> && cd <repo>
# 运行 /uv-env-setup → 执行 uv sync（默认）
```

### 部署/Docker（prod 模式）
用户说"帮我配置 prod 环境"或"生产部署"：
```bash
uv sync --no-dev
```

### Python 版本升级
```bash
uv python pin 3.12
rm -rf .venv
uv sync   # 重建（含 dev）
```

### 依赖更新后同步
```bash
# pyproject.toml 或 uv.lock 有变更
uv sync   # 幂等操作，安全重复执行
```
