# Python 项目结构：uv + FastAPI + Gradio

## 推荐项目结构

```
my-project/
├── src/
│   └── my_package/
│       ├── __init__.py
│       ├── config.py           # 集中配置（pydantic-settings）
│       ├── exceptions.py       # 自定义异常
│       ├── models/             # Pydantic 数据模型
│       │   ├── __init__.py
│       │   └── schemas.py
│       ├── api/                # FastAPI 路由层
│       │   ├── __init__.py
│       │   ├── app.py          # FastAPI 应用入口
│       │   ├── deps.py         # 依赖注入
│       │   └── routes/
│       │       ├── __init__.py
│       │       └── items.py
│       ├── ui/                 # Gradio 界面层
│       │   ├── __init__.py
│       │   └── app.py          # Gradio 应用入口
│       ├── services/           # 业务逻辑
│       │   ├── __init__.py
│       │   └── item_service.py
│       └── utils/              # 工具函数
│           ├── __init__.py
│           └── data.py
├── tests/
│   ├── conftest.py
│   ├── api/                    # FastAPI 路由测试
│   │   └── test_items.py
│   └── services/
│       └── test_item_service.py
├── scripts/                    # 运维/数据脚本
│   └── seed_data.py
├── pyproject.toml              # 所有配置
├── uv.lock                     # 锁文件（提交到 git）
├── .env.example                # 环境变量模板（提交到 git）
├── .env                        # 本地配置（不提交）
├── CLAUDE.md                   # Claude 项目指令
└── README.md
```

---

## pyproject.toml 完整模板（uv + FastAPI + Gradio）

```toml
[project]
name = "my-project"
version = "0.1.0"
description = "FastAPI + Gradio 应用"
requires-python = ">=3.10"
dependencies = [
    "fastapi>=0.115",
    "uvicorn[standard]>=0.30",
    "gradio>=5.0",
    "pydantic>=2.0",
    "pydantic-settings>=2.0",
    # 数据处理（按需）
    "pandas>=2.0",
    "httpx>=0.27",  # 异步 HTTP 客户端
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov",
    "pytest-asyncio",
    "httpx",         # FastAPI TestClient 所需
    "ruff",
    "mypy",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

# ────────── 工具配置 ──────────

[tool.ruff]
target-version = "py310"
line-length = 88

[tool.ruff.lint]
select = ["E", "W", "F", "I", "N", "UP", "B", "C4", "SIM", "TCH"]
ignore = ["E501"]

[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101"]

[tool.mypy]
python_version = "3.10"
strict = true
ignore_missing_imports = true

# Gradio / pandas 没有完整类型存根
[[tool.mypy.overrides]]
module = ["gradio.*", "pandas.*", "numpy.*"]
ignore_missing_imports = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"   # pytest-asyncio 自动模式
addopts = ["-v", "--tb=short"]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "scripts/*"]
```

---

## uv 常用命令

```bash
# 初始化新项目
uv init my-project && cd my-project

# 添加运行时依赖
uv add fastapi "uvicorn[standard]" gradio pydantic-settings

# 添加开发依赖
uv add --dev ruff mypy pytest pytest-cov pytest-asyncio httpx

# 安装所有依赖（clone 后首次运行）
uv sync

# 运行任何命令（无需手动激活 venv）
uv run ruff check .
uv run pytest
uv run uvicorn src.myapp.api.app:app --reload

# 更新依赖
uv lock --upgrade && uv sync

# 查看依赖树
uv tree
```

---

## FastAPI 应用入口

```python
# src/my_package/api/app.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from my_package.api.routes import items
from my_package.config import settings
from my_package.exceptions import AppError

app = FastAPI(title=settings.app_name, version=settings.app_version)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(items.router, prefix="/api/v1/items", tags=["items"])


@app.exception_handler(AppError)
async def app_error_handler(request, exc: AppError) -> JSONResponse:
    status_map: dict[str, int] = {
        "NotFoundError": 404,
        "ValidationError": 422,
        "DuplicateError": 409,
    }
    status = status_map.get(type(exc).__name__, 500)
    return JSONResponse(
        status_code=status,
        content={"error": exc.code, "message": exc.message},
    )
```

## Gradio 应用（调用 service 层）

```python
# src/my_package/ui/app.py
import gradio as gr
from my_package.services.item_service import ItemService

service = ItemService()

def process(input_text: str) -> str:
    result = service.process(input_text)
    return result.output

demo = gr.Interface(
    fn=process,
    inputs=gr.Textbox(label="输入"),
    outputs=gr.Textbox(label="输出"),
    title="My App",
)

if __name__ == "__main__":
    demo.launch()
```

---

## 配置管理（pydantic-settings + .env）

```python
# src/my_package/config.py
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    app_name: str = "My App"
    app_version: str = "0.1.0"
    debug: bool = False
    allowed_origins: list[str] = Field(default=["http://localhost:3000"])


settings = Settings()
```

```bash
# .env.example （提交到 git，不含真实密钥）
APP_NAME=My App
DEBUG=false
```

---

## FastAPI 测试（TestClient）

```python
# tests/api/test_items.py
from fastapi.testclient import TestClient
from my_package.api.app import app

client = TestClient(app)

def test_get_item_success() -> None:
    response = client.get("/api/v1/items/1")
    assert response.status_code == 200

def test_get_item_not_found() -> None:
    response = client.get("/api/v1/items/99999")
    assert response.status_code == 404
    assert response.json()["error"] == "NotFoundError"
```

---

## .gitignore 要点

```gitignore
# 环境
.env
.venv/
venv/

# uv.lock 要提交！不要 ignore
# uv.lock  ← 不要加这行

# Python
__pycache__/
*.py[cod]
.mypy_cache/
.ruff_cache/
.pytest_cache/

# 覆盖率
.coverage
htmlcov/
```
