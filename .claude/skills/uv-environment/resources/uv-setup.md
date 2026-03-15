# UV 项目设置指南

## 新项目初始化

```bash
# 1. 创建项目
uv init my-project
cd my-project

# 2. 锁定 Python 版本（强烈推荐）
uv python pin 3.11

# 3. 添加依赖
uv add fastapi "uvicorn[standard]" pydantic pydantic-settings

# 4. 添加开发依赖
uv add --dev ruff mypy pytest pytest-cov pytest-asyncio httpx

# 5. 验证环境
uv run python --version
uv tree
```

---

## pyproject.toml 完整模板

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "FastAPI + Gradio 应用"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115",
    "uvicorn[standard]>=0.30",
    "pydantic>=2.0",
    "pydantic-settings>=2.0",
]

# ─── 开发依赖（dev 模式才安装）───────────────────
[dependency-groups]
dev = [
    "ruff>=0.9",
    "mypy>=1.14",
    "pytest>=8.0",
    "pytest-cov",
    "pytest-asyncio",
    "httpx",           # FastAPI TestClient
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

# ─── 工具配置 ────────────────────────────────────

[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "C4", "SIM", "TCH"]
ignore = ["E501"]

[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101"]

[tool.mypy]
python_version = "3.11"
strict = true
ignore_missing_imports = true

[[tool.mypy.overrides]]
module = ["gradio.*", "pandas.*", "numpy.*"]
ignore_missing_imports = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
addopts = ["-v", "--tb=short"]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "scripts/*"]
```

---

## Dev vs Prod 环境操作

### 本地开发（Dev 模式）

```bash
# 克隆仓库后
git clone <repo>
cd <repo>

# 一条命令恢复完整开发环境
uv sync   # 默认包含 dev dependencies

# 验证
uv run python --version
uv run pytest --co -q  # 只列出测试，不运行
```

### 生产部署（Prod 模式）

```bash
# Dockerfile 或部署脚本中
uv sync --no-dev       # 仅安装生产依赖，体积更小

# 启动服务
uv run uvicorn src.myapp.api.app:app --host 0.0.0.0 --port 8000
```

### Docker 多阶段构建示例

```dockerfile
FROM python:3.11-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app
COPY pyproject.toml uv.lock ./

# Prod 模式：不安装 dev 依赖
RUN uv sync --no-dev --frozen

FROM python:3.11-slim
COPY --from=builder /app/.venv /app/.venv
COPY src/ /app/src/

# 不需要激活 venv，直接使用
CMD ["/app/.venv/bin/uvicorn", "src.myapp.api.app:app", "--host", "0.0.0.0"]
```

---

## CI/CD 集成（GitHub Actions）

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true    # 缓存 .venv，大幅加速 CI

      - name: Install dependencies (dev mode)
        run: uv sync   # 默认包含 dev dependencies

      - name: Lint & Format check
        run: |
          uv run ruff format --check .
          uv run ruff check .

      - name: Type check
        run: uv run mypy .

      - name: Run tests
        run: uv run pytest --cov=src --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
```

---

## .gitignore 清单

```gitignore
# Python
__pycache__/
*.py[cod]
*.so

# UV venv（不提交）
.venv/

# 工具缓存（不提交）
.mypy_cache/
.ruff_cache/
.pytest_cache/
.coverage
htmlcov/

# 环境变量（不提交，只提交 .env.example）
.env

# ⚠️ 不要 ignore uv.lock！
# uv.lock  ← 删掉这行如果你有的话
```

---

## 常用依赖安装速查

```bash
# Web 框架
uv add fastapi "uvicorn[standard]" httpx

# AI / ML
uv add openai anthropic torch transformers

# 数据处理
uv add pandas numpy polars

# 数据库
uv add sqlalchemy "psycopg[binary]" alembic

# UI
uv add gradio streamlit

# 开发工具（全部用 --dev）
uv add --dev ruff mypy pytest pytest-cov pytest-asyncio
uv add --dev ipython rich  # 调试辅助
```
