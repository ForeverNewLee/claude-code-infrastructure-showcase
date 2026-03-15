---
name: uv-environment
description: UV Python 环境管理技能。当初始化 Python 项目、安装/更新依赖、切换 dev/prod 模式、处理 venv 环境问题、配置 pyproject.toml，或看到任何 pip/virtualenv 相关操作时自动激活。确保始终使用 uv 管理 Python 环境。
---

# UV Environment Management

## 三条黄金原则

> 记住这三条，其他都是细节。

```
1. pyproject.toml 声明依赖  →  唯一真相来源
2. uv sync 安装/同步         →  克隆后第一件事
3. uv run 执行所有命令       →  永远不要手动激活 venv
```

**为什么不用 `source .venv/bin/activate`？**
- `uv run` 自动定位并使用正确的 venv，无需激活
- 避免"忘记激活"或"激活了错误的 venv"
- 脚本和 hooks 里的行为完全一致

---

## 核心命令速查

```bash
# ── 环境初始化 ──────────────────────────────────
uv init my-project          # 新建项目（创建 pyproject.toml）
uv sync                     # 安装所有依赖（含 dev）← 克隆后首先运行
uv sync --no-dev            # 仅安装生产依赖（prod 部署用）

# ── 依赖管理 ────────────────────────────────────
uv add fastapi uvicorn      # 添加运行时依赖
uv add --dev ruff mypy pytest  # 添加开发依赖
uv remove requests          # 移除依赖
uv lock --upgrade && uv sync   # 升级所有依赖到最新版本

# ── 运行命令（核心！）──────────────────────────
uv run python script.py     # 运行 Python 脚本
uv run ruff format .        # 格式化
uv run ruff check . --fix   # Lint + 自动修复
uv run mypy .               # 类型检查
uv run pytest               # 运行测试
uv run uvicorn app:app --reload  # 启动 FastAPI

# ── 环境信息 ────────────────────────────────────
uv tree                     # 查看依赖树
uv python list              # 查看可用 Python 版本
uv python pin 3.11          # 锁定 Python 版本（创建 .python-version）
```

---

## Dev vs Prod 模式

| 操作 | Dev 模式 | Prod 模式 |
|------|---------|---------|
| 安装命令 | `uv sync`（默认） | `uv sync --no-dev` |
| 包含依赖 | `dependencies` + `dev` group | 仅 `dependencies` |
| 典型场景 | 本地开发、CI 测试 | Docker 镜像、部署 |

```toml
# pyproject.toml — 依赖分组
[project]
dependencies = [
    "fastapi>=0.115",
    "uvicorn[standard]>=0.30",
]

[dependency-groups]
dev = [
    "ruff>=0.9",
    "mypy>=1.14",
    "pytest>=8.0",
    "pytest-cov",
    "pytest-asyncio",
    "httpx",  # FastAPI TestClient
]
```

---

## uv.lock — 必须提交到 Git

```gitignore
# ✅ 这些应该提交
pyproject.toml
uv.lock          # ← 绝对不要 ignore 这个！

# ❌ 这些不提交
.venv/
.env
```

**为什么 `uv.lock` 要提交？**
- 锁定所有直接 + 间接依赖的精确版本
- 保证团队成员、CI、部署环境完全一致
- 等价于 `package-lock.json`（npm）或 `Cargo.lock`（Rust）

---

## 质量链（每次写完代码必跑）

```bash
# 完整质量链
uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest

# 分步骤（任一失败停止）
uv run ruff format .         # Step 1: 格式化
uv run ruff check . --fix   # Step 2: Lint
uv run mypy .                # Step 3: 类型检查
uv run pytest                # Step 4: 测试
```

---

## 快速导航

| 需要了解... | 读这个 |
|---|---|
| 项目初始化 & dev/prod 配置模板 | [uv-setup.md](resources/uv-setup.md) |
| 常见报错与修复 | [uv-troubleshooting.md](resources/uv-troubleshooting.md) |

## 相关技能

- **python-dev-guidelines** — 代码质量规范（ruff/mypy/pytest 详细配置）
- **tdd-workflow** — TDD 引导流程

---

**Skill Status**: COMPLETE ✅
