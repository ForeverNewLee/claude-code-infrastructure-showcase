# Testing Guide: pytest + TDD

## 核心原则

> **AI 生成的代码，未经测试都是废品。**

TDD（测试驱动开发）工作流：
1. **先让 AI 写测试**（描述期望行为）
2. **再让 AI 实现功能**（满足测试）
3. **运行质量链**：`pytest` → `ruff` → `mypy`

---

## 安装

```bash
# 使用 uv（推荐）
uv add --dev pytest pytest-cov pytest-asyncio
```

---

## pyproject.toml 配置

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = [
    "-v",               # 详细输出
    "--tb=short",       # 简短 traceback
    "--strict-markers", # 未注册的 marker 报错
]
markers = [
    "slow: 标记为慢速测试",
    "integration: 集成测试",
]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]

[tool.coverage.report]
show_missing = true
precision = 2
```

---

## TDD 工作流（配合 Claude Code）

### Step 1: 让 AI 先写测试

**Prompt 示例：**
```
我需要一个 UserService，功能是：
1. 通过 ID 查找用户（找不到抛 UserNotFoundError）
2. 创建用户（邮箱重复抛 DuplicateEmailError）
3. 删除用户

先帮我写 pytest 测试，不要实现功能。
```

**AI 生成的测试结构：**
```python
# tests/test_user_service.py
import pytest
from myapp.services.user_service import UserService
from myapp.exceptions import UserNotFoundError, DuplicateEmailError

class TestGetUser:
    def test_get_existing_user(self, user_service, existing_user):
        user = user_service.get_user(existing_user.id)
        assert user.id == existing_user.id
        assert user.email == existing_user.email

    def test_get_nonexistent_user(self, user_service):
        with pytest.raises(UserNotFoundError):
            user_service.get_user(user_id=99999)

class TestCreateUser:
    def test_create_user_success(self, user_service):
        user = user_service.create_user(name="Alice", email="alice@example.com")
        assert user.id is not None
        assert user.email == "alice@example.com"

    def test_create_user_duplicate_email(self, user_service, existing_user):
        with pytest.raises(DuplicateEmailError):
            user_service.create_user(name="Bob", email=existing_user.email)
```

### Step 2: 让 AI 实现功能（基于测试）

**Prompt 示例：**
```
现在帮我实现 UserService，使上面的测试通过。
```

### Step 3: 验证

```bash
uv run pytest tests/test_user_service.py -v
```

---

## conftest.py — Fixtures 最佳实践

```python
# tests/conftest.py
import pytest
from unittest.mock import MagicMock, AsyncMock
from myapp.services.user_service import UserService
from myapp.models import User

@pytest.fixture
def mock_user_repo():
    """Mock 用户仓库"""
    return MagicMock()

@pytest.fixture
def user_service(mock_user_repo):
    """被测试的 UserService"""
    return UserService(user_repo=mock_user_repo)

@pytest.fixture
def existing_user(mock_user_repo):
    """预设存在的用户"""
    user = User(id=1, name="Test User", email="test@example.com")
    mock_user_repo.get_by_id.return_value = user
    mock_user_repo.get_by_email.return_value = user
    return user

@pytest.fixture
def empty_user_repo(mock_user_repo):
    """空仓库（查询返回 None）"""
    mock_user_repo.get_by_id.return_value = None
    mock_user_repo.get_by_email.return_value = None
    return mock_user_repo
```

---

## 测试覆盖三层

每个功能模块都需要覆盖：

```python
class TestMyFunction:
    # 1. 正常路径（Happy Path）
    def test_success_case(self): ...

    # 2. 边界条件（Edge Cases）
    def test_empty_input(self): ...
    def test_max_value(self): ...
    def test_zero(self): ...

    # 3. 异常路径（Error Cases）
    def test_raises_on_invalid_input(self): ...
    def test_raises_on_not_found(self): ...
```

---

## 常用测试模式

### Mock 外部依赖

```python
from unittest.mock import patch, MagicMock

def test_send_email_called(user_service):
    with patch("myapp.services.email_service.send") as mock_send:
        user_service.register(email="new@example.com")
        mock_send.assert_called_once_with(
            to="new@example.com",
            subject="Welcome"
        )
```

### 参数化测试

```python
@pytest.mark.parametrize("email,expected", [
    ("valid@example.com", True),
    ("invalid-email", False),
    ("", False),
    ("@no-local.com", False),
])
def test_email_validation(email: str, expected: bool):
    assert is_valid_email(email) == expected
```

### 异步测试

```python
import pytest

@pytest.mark.asyncio
async def test_async_get_user(async_user_service):
    user = await async_user_service.get_user(user_id=1)
    assert user.id == 1
```

### 临时文件测试

```python
def test_file_processor(tmp_path):
    # tmp_path 是 pytest 提供的临时目录 fixture
    test_file = tmp_path / "test.txt"
    test_file.write_text("hello")

    result = process_file(str(test_file))
    assert result == "HELLO"
```

---

## 覆盖率报告

```bash
# 生成覆盖率报告
uv run pytest --cov=src --cov-report=term-missing

# 生成 HTML 报告
uv run pytest --cov=src --cov-report=html
open htmlcov/index.html

# 设置最低覆盖率门槛（CI 中使用）
uv run pytest --cov=src --cov-fail-under=80
```

---

## 交叉 AI Review 工作流

**在完成功能后，开新对话（或用不同模型）：**

```
这是我刚实现的 [功能名] 的代码变更：
[粘贴 git diff 或代码]

请帮我 review：
1. 有没有潜在的 bug 或边界情况未覆盖？
2. 测试是否充分？
3. 有没有违反 Python 最佳实践？
4. 类型注解是否完整？
```

这个步骤往往能发现：
- 并发安全问题
- 未处理的 None 情况
- 测试覆盖遗漏的边界
- 性能问题

---

## Anti-Patterns

| 问题 | 错误做法 | 正确做法 |
|------|---------|---------|
| 测试名不清晰 | `test_1()` | `test_get_user_returns_none_when_not_found()` |
| 测试多个功能 | 一个 test 函数测 3 个行为 | 每个行为一个 test 函数 |
| Mock 过度 | Mock 一切，包括被测代码本身 | 只 Mock 外部依赖 |
| 跳过失败测试 | `@pytest.mark.skip` 永久跳过 | 修复或记录 issue |
| 测试依赖顺序 | test_b 依赖 test_a 的副作用 | 每个测试独立，用 fixtures |
