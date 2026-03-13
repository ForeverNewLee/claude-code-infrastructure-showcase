# Test-First: TDD Resource Files

## Prompt 模板库

这里收录了"让 AI 先写测试再实现"的高效 prompt 模板。

---

## 功能开发 Prompt（最常用）

### 模板 1: 服务类 / 业务逻辑

```
我需要实现 [ClassName] 类，功能是：
1. [方法名]: [做什么，输入是什么，返回什么]
2. [方法名]: [做什么，失败时抛 XxxError]

依赖：[需要注入的依赖，如 repo、外部服务]

请先只写 pytest 测试（不要实现），覆盖：
- 每个方法的正常路径
- 边界情况（空值、None、空列表等）
- 异常路径（用 pytest.raises）

使用 fixtures 注入依赖（Mock/MagicMock）。
```

### 模板 2: 工具函数 / 纯函数

```
我需要一个函数 [function_name]：
- 输入: [参数及类型]
- 输出: [返回值及类型]
- 规则: [业务规则]
- 边界: [边界情况处理]
- 错误: [何时抛异常]

先帮我写 pytest 测试，包括：
- @pytest.mark.parametrize 测试多个输入/输出组合
- 边界测试
- 异常测试
```

### 模板 3: API 端点（FastAPI）

```
我需要 [HTTP方法] [/path] 端点：
- 请求体: [字段 + 类型]
- 成功响应: [状态码 + 响应结构]
- 错误情况: [什么情况返回 4xx，携带什么信息]

先帮我写 pytest + httpx/TestClient 测试，覆盖：
- 正常请求成功
- 缺失必填字段 → 422
- 业务错误（如资源不存在 → 404）
- 认证失败（如有认证）→ 401
```

---

## 测试文件结构规范

```python
# tests/test_<module_name>.py
"""
Tests for <Module/Class description>.

Test organization:
- Test<HappyPath>: Normal, expected behavior
- Test<EdgeCases>: Boundary conditions
- Test<ErrorCases>: Exception paths
"""
import pytest
from unittest.mock import MagicMock, patch, AsyncMock

# Import what we're testing
from myapp.<module> import <ClassName>
# Import custom exceptions
from myapp.exceptions import <RelevantError>


# ── Fixtures ──────────────────────────────────────────────────────────────────

@pytest.fixture
def mock_<dependency>() -> MagicMock:
    """Mock <dependency description>."""
    mock = MagicMock()
    # Set up default return values
    mock.get.return_value = None
    return mock


@pytest.fixture
def <subject>(mock_<dependency>: MagicMock) -> <ClassName>:
    """<ClassName> instance under test."""
    return <ClassName>(<dependency>=mock_<dependency>)


@pytest.fixture
def sample_<entity>() -> dict:
    """Sample <entity> data for tests."""
    return {
        "id": 1,
        "name": "Test Entity",
    }


# ── Test Classes ──────────────────────────────────────────────────────────────

class Test<MethodName>HappyPath:
    """Normal behavior for <method_name>."""

    def test_<action>_returns_<expected>(
        self,
        <subject>: <ClassName>,
        sample_<entity>: dict,
    ) -> None:
        # Arrange
        expected = ...
        # Act
        result = <subject>.<method_name>(...)
        # Assert
        assert result == expected


class Test<MethodName>EdgeCases:
    """Edge cases for <method_name>."""

    def test_<action>_with_empty_input(self, <subject>: <ClassName>) -> None:
        ...

    @pytest.mark.parametrize("input_val,expected", [
        (None, None),
        ([], []),
        ("", ""),
    ])
    def test_<action>_with_various_inputs(
        self,
        <subject>: <ClassName>,
        input_val: ...,
        expected: ...,
    ) -> None:
        result = <subject>.<method_name>(input_val)
        assert result == expected


class Test<MethodName>ErrorCases:
    """Error conditions for <method_name>."""

    def test_<action>_raises_<error>_when_<condition>(
        self,
        <subject>: <ClassName>,
    ) -> None:
        with pytest.raises(<ErrorClass>) as exc_info:
            <subject>.<method_name>(...)

        assert "expected text" in str(exc_info.value)
```

---

## TDD 工作流检查清单

**开始新功能时：**
- [ ] 明确需求（输入/输出/错误情况）
- [ ] Prompt AI 生成测试（不要实现）
- [ ] 检查测试设计：覆盖全了吗？
- [ ] 确认后 Prompt AI 生成实现
- [ ] 运行 `pytest -v` 验证

**完成后：**
- [ ] `ruff format . && ruff check . --fix`
- [ ] `mypy .`
- [ ] `pytest --cov=src --cov-report=term-missing`
- [ ] 覆盖率 >= 80%？
- [ ] 做交叉 AI review

---

## 常见的测试覆盖遗漏

| 场景 | 容易遗漏的测试 |
|------|--------------|
| List 操作 | 空列表、单元素列表、很大的列表 |
| 字符串处理 | 空字符串、只有空白、Unicode 字符 |
| 数字计算 | 零值、负数、浮点精度 |
| 外部 API 调用 | 超时、网络错误、返回格式异常 |
| 数据库操作 | 记录不存在、唯一性冲突、连接失败 |
| 文件操作 | 文件不存在、权限不够、磁盘满 |
| 并发 | 竞态条件（如果有状态的话） |
