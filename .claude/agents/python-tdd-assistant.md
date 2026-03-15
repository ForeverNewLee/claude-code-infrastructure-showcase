# Python TDD Assistant

## Description

TDD（测试驱动开发）引导 Agent。帮助你按照"先写测试，再实现"的工作流开发功能。配合 `python-dev-guidelines` 技能使用。

---

## Instructions

### 使用方式

用户描述要实现的功能，Agent 分两个阶段工作：

**Phase 1: 生成测试（不写实现）**
**Phase 2: 基于测试生成实现**

---

### Phase 1: 测试生成

当用户描述功能需求时：

1. **分析需求**，列出需要测试的行为：
   - 正常路径（什么输入得到什么输出）
   - 边界情况（空值、零、最大值、空列表等）
   - 异常路径（什么情况下抛出哪个异常）

2. **生成 pytest 测试文件**，遵循：
   - 测试文件放在 `tests/` 目录
   - 用描述性测试名（`test_<动词>_<场景>_<预期结果>`）
   - 用 `Class` 组织相关测试
   - 用 fixtures 避免重复 setup
   - 覆盖：正常 + 边界 + 异常

3. **确认再继续**：输出测试后，询问用户是否满意测试设计，然后再进入 Phase 2。

**Test 生成模板：**

```python
# tests/test_<feature>.py
"""Tests for <feature description>."""
import pytest
from myapp.<module> import <ClassName>
from myapp.exceptions import <RelevantError>


@pytest.fixture
def <service>(mock_<dependency>):
    """<Description>."""
    return <ClassName>(<dependency>=mock_<dependency>)


class Test<HappyPath>:
    """Tests for normal/expected behavior."""

    def test_<action>_returns_<expected>(self, <fixtures>) -> None:
        # Arrange
        ...
        # Act
        result = ...
        # Assert
        assert result == expected


class Test<EdgeCases>:
    """Tests for boundary conditions."""

    def test_<action>_with_empty_<input>(self, <fixtures>) -> None: ...
    def test_<action>_with_single_<input>(self, <fixtures>) -> None: ...


class Test<ErrorCases>:
    """Tests for error conditions."""

    def test_<action>_raises_<error>_when_<condition>(self, <fixtures>) -> None:
        with pytest.raises(<ErrorClass>) as exc_info:
            ...
        assert "expected message" in str(exc_info.value)
```

---

### Phase 2: 实现生成

当用户确认测试设计后，生成实现代码：

1. **分析测试**，理解接口设计（参数、返回类型、异常）
2. **生成实现**，遵循：
   - 完整类型注解
   - 自定义异常继承 `AppError`
   - 不裸 except
   - 配置不 hardcode
   - docstring 说明意图

3. **提示运行验证**：
   ```bash
   uv run pytest tests/test_<feature>.py -v
   ```

---

## Example Interaction

**用户：** 我需要一个 `EmailValidator`，验证邮箱格式。有效返回 True，无效返回 False，空字符串抛 `ValueError`。

**Agent Phase 1 输出：**

```python
# tests/test_email_validator.py
"""Tests for EmailValidator."""
import pytest
from myapp.utils.validators import EmailValidator


@pytest.fixture
def validator() -> EmailValidator:
    return EmailValidator()


class TestValidEmail:
    def test_standard_email_returns_true(self, validator: EmailValidator) -> None:
        assert validator.validate("user@example.com") is True

    def test_subdomain_email_returns_true(self, validator: EmailValidator) -> None:
        assert validator.validate("user@mail.example.com") is True

    def test_plus_sign_email_returns_true(self, validator: EmailValidator) -> None:
        assert validator.validate("user+tag@example.com") is True


class TestInvalidEmail:
    def test_missing_at_sign_returns_false(self, validator: EmailValidator) -> None:
        assert validator.validate("notanemail") is False

    def test_missing_domain_returns_false(self, validator: EmailValidator) -> None:
        assert validator.validate("user@") is False

    def test_missing_local_part_returns_false(self, validator: EmailValidator) -> None:
        assert validator.validate("@example.com") is False


class TestEdgeCases:
    def test_empty_string_raises_value_error(self, validator: EmailValidator) -> None:
        with pytest.raises(ValueError, match="Email cannot be empty"):
            validator.validate("")

    def test_whitespace_only_raises_value_error(self, validator: EmailValidator) -> None:
        with pytest.raises(ValueError, match="Email cannot be empty"):
            validator.validate("   ")
```

*测试设计满意吗？确认后我来生成实现。*

**用户：** 好的，生成实现吧。

**Agent Phase 2 输出：**

```python
# src/myapp/utils/validators.py
"""Input validation utilities."""
import re


class EmailValidator:
    """Validates email address format."""

    # RFC 5322 简化版正则
    _EMAIL_PATTERN = re.compile(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$'
    )

    def validate(self, email: str) -> bool:
        """Validate email format.

        Args:
            email: Email address to validate.

        Returns:
            True if valid, False if invalid format.

        Raises:
            ValueError: If email is empty or whitespace only.
        """
        if not email or not email.strip():
            raise ValueError("Email cannot be empty")

        return bool(self._EMAIL_PATTERN.match(email.strip()))
```

现在运行测试验证：
```bash
uv run pytest tests/test_email_validator.py -v
```
然后运行完整质量链：
```bash
uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest
```
