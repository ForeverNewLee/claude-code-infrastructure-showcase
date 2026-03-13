# Code Quality: ruff + mypy

## ruff — 一个工具取代所有

ruff 同时负责：
- **格式化**（取代 black）
- **Import 排序**（取代 isort）
- **Linting**（取代 flake8 + 多个插件）

### 安装

```bash
pip install ruff mypy
# 或
uv add --dev ruff mypy
```

---

## pyproject.toml 完整配置

```toml
[tool.ruff]
target-version = "py310"
line-length = 88

[tool.ruff.lint]
# 启用的规则集
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "N",   # pep8-naming
    "UP",  # pyupgrade（自动升级旧语法）
    "B",   # flake8-bugbear（常见 bug 模式）
    "C4",  # flake8-comprehensions
    "SIM", # flake8-simplify
    "TCH", # flake8-type-checking（TYPE_CHECKING 优化）
]
ignore = [
    "E501",  # 行长度（交给 formatter 处理）
]

[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101"]  # 允许测试中使用 assert

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

---

## ruff 常用命令

```bash
# 检查所有文件（不修改）
ruff check .

# 检查 + 自动修复
ruff check . --fix

# 格式化所有文件
ruff format .

# 只检查单个文件
ruff check src/myapp/service.py

# 查看某条规则的说明
ruff rule B006
```

---

## mypy — 严格类型检查

### pyproject.toml 配置

```toml
[tool.mypy]
python_version = "3.10"
strict = true           # 启用所有严格检查

# 常用严格选项（strict 已包含，显式列出供参考）
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
check_untyped_defs = true
no_implicit_optional = true

# 忽略没有 stub 的第三方库
ignore_missing_imports = true

# 报告文件（可选）
# html_report = "mypy-report"
```

### 渐进式启用（不要一步到严格）

```toml
# 第 1 阶段：只检查类型一致性
[tool.mypy]
python_version = "3.10"
ignore_missing_imports = true

# 第 2 阶段：要求函数注解
disallow_untyped_defs = true

# 第 3 阶段：完全严格
strict = true
```

---

## 常见类型注解模式

```python
from __future__ import annotations  # 允许 forward reference

from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from myapp.models import User

# 基本类型
def greet(name: str) -> str:
    return f"Hello, {name}"

# Optional
def find_user(user_id: int) -> User | None:  # Python 3.10+
    ...

# Union（Python 3.10+ 用 |）
def process(data: str | bytes) -> str:
    ...

# List/Dict
def get_tags(post_id: int) -> list[str]:
    ...

def get_config() -> dict[str, str]:
    ...

# Callable
from collections.abc import Callable
def retry(fn: Callable[..., str], times: int) -> str:
    ...

# TypeVar（泛型）
from typing import TypeVar
T = TypeVar("T")

def first(items: list[T]) -> T | None:
    return items[0] if items else None
```

---

## 常见 ruff 规则说明与修复

### B006 — 可变默认参数

```python
# ❌ ruff B006
def add_item(item: str, items: list[str] = []) -> list[str]:
    items.append(item)
    return items

# ✅ 正确
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items
```

### UP007 — 使用新 Union 语法

```python
# ❌ ruff UP007（旧语法）
from typing import Optional, Union
def foo(x: Optional[str]) -> Union[str, int]: ...

# ✅ ruff 自动修复为
def foo(x: str | None) -> str | int: ...
```

### SIM108 — 简化三元表达式

```python
# ❌ ruff SIM108
if condition:
    result = "yes"
else:
    result = "no"

# ✅ 正确
result = "yes" if condition else "no"
```

### TCH001/TCH002 — TYPE_CHECKING 优化

```python
# ✅ 只在类型检查时导入（避免运行时开销）
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from myapp.models import HeavyModel

def process(model: HeavyModel) -> None: ...
```

---

## CI/CD 集成

```yaml
# .github/workflows/quality.yml
- name: Lint & Format Check
  run: |
    ruff format --check .
    ruff check .

- name: Type Check
  run: mypy .
```

---

## Anti-Patterns 速查

| 问题 | 错误 | 正确 |
|------|------|------|
| 裸 except | `except:` | `except ValueError as e:` |
| 可变默认参数 | `def f(x=[])` | `def f(x=None)` |
| 未注解函数 | `def f(x):` | `def f(x: int) -> str:` |
| 旧 Union 语法 | `Optional[str]` | `str \| None` |
| 直接使用 print | `print(error)` | `logger.exception(error)` |
