---
name: python-dev-guidelines
description: Python 开发规范技能。当创建或修改 Python 文件、配置 ruff/mypy、编写 pytest 测试、处理异常、设计项目结构，或进行 Python 代码 review 时自动激活。涵盖代码质量（ruff + mypy）、TDD 工作流（pytest）、项目结构、异常处理等最佳实践。
---

# Python Development Guidelines

## 核心原则

这套规范来自实际 Python 项目经验，核心思路：**把 AI 当实习生，但要给实习生配好 SOP**。

- ✅ **质量门禁**：ruff → mypy → pytest，每次写完代码必须过
- ✅ **TDD 先行**：先写测试，再实现功能
- ✅ **类型标注**：所有函数签名必须有类型注解
- ✅ **交叉评审**：AI 生成的代码，再找另一个 AI 来 review

---

## 前提：使用 UV 管理环境

> ⚠️ **所有命令必须通过 `uv run` 执行**，确保使用项目 venv 里的正确版本。
> 如果环境未初始化，先运行：`uv sync`
> 详细 UV 使用方法见 **uv-environment** 技能。

---

## 质量检查命令（每次必跑）

```bash
# 格式化（先格式化，再 lint）
uv run ruff format .

# Lint + 自动修复
uv run ruff check . --fix

# 类型检查
uv run mypy .

# 测试
uv run pytest

# 一键全部
uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest
```

> **永远记住：AI 生成的代码，未经测试都是废品。**

---

## 新功能开发 Checklist

- [ ] 先写测试（`tests/test_xxx.py`）
- [ ] 实现功能代码
- [ ] `uv run ruff format .` — 格式化
- [ ] `uv run ruff check . --fix` — lint 修复
- [ ] `uv run mypy .` — 类型检查通过
- [ ] `uv run pytest` — 所有测试通过
- [ ] 提交前做交叉 review

---

## 项目结构（推荐 src layout）

```
my-project/
├── src/
│   └── my_package/
│       ├── __init__.py
│       ├── models/          # 数据模型
│       ├── services/        # 业务逻辑
│       ├── utils/           # 工具函数
│       └── exceptions.py    # 自定义异常
├── tests/
│   ├── conftest.py          # pytest fixtures
│   ├── test_services/
│   └── test_utils/
├── pyproject.toml           # 项目配置（all-in-one）
├── uv.lock                  # 锁文件（必须提交到 git）
├── CLAUDE.md                # Claude 项目指令
└── README.md
```

---

## 7 条核心规则

### 1. 所有函数必须有类型注解

```python
# ❌ 不可接受
def get_user(user_id):
    return db.query(user_id)

# ✅ 正确
def get_user(user_id: int) -> User | None:
    return db.query(user_id)
```

### 2. 不要裸 except

```python
# ❌ 不可接受
try:
    result = risky_operation()
except:
    pass

# ✅ 正确
try:
    result = risky_operation()
except ValueError as e:
    logger.error("Invalid input: %s", e)
    raise
```

### 3. 使用自定义异常（不要直接抛 Exception）

```python
# ❌ 不可接受
raise Exception("User not found")

# ✅ 正确
class UserNotFoundError(AppError):
    pass

raise UserNotFoundError(f"User {user_id} not found")
```

### 4. 将配置集中管理（不散落 hardcode）

```python
# ❌ 不可接受
timeout = 30  # hardcode

# ✅ 正确
from myapp.config import settings
timeout = settings.request_timeout
```

### 5. 测试必须覆盖正常路径 + 边界 + 异常

```python
def test_get_user_success(): ...
def test_get_user_not_found(): ...
def test_get_user_invalid_id(): ...
```

### 6. 使用 dataclasses 或 Pydantic 做数据结构

```python
from dataclasses import dataclass

@dataclass
class UserCreateDTO:
    name: str
    email: str
    age: int
```

### 7. 生成的代码必须交叉 review

用不同的 AI（如另一个 Claude 对话）把变更喂进去，问："这段代码有什么潜在问题？"

---

## 快速导航

| 需要了解... | 读这个 |
|------------|--------|
| ruff/mypy 详细配置 | [code-quality.md](resources/code-quality.md) |
| pytest TDD 工作流 | [testing-guide.md](resources/testing-guide.md) |
| 项目结构和 pyproject.toml | [project-structure.md](resources/project-structure.md) |
| 异常设计与错误处理 | [error-handling.md](resources/error-handling.md) |

---

## 相关技能

- **uv-environment** — UV 环境管理（初始化、dev/prod 模式、uv.lock）
- **tdd-workflow** — TDD 引导与交叉 review 流程
- **skill-developer** — 创建和管理新技能

---

**Skill Status**: COMPLETE ✅
**Line Count**: < 500 ✅
**Progressive Disclosure**: 4 resource files ✅
