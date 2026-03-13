# Python 错误处理与异常设计

## 核心原则

1. **用自定义异常，不直接抛 `Exception`**
2. **每个异常携带足够上下文信息**
3. **在最合适的层面捕获，不要吞掉异常**
4. **区分"预期异常"和"编程错误"**

---

## 异常层次设计

```python
# src/myapp/exceptions.py

class AppError(Exception):
    """应用层基础异常，所有业务异常继承此类"""
    def __init__(self, message: str, *, code: str | None = None) -> None:
        super().__init__(message)
        self.message = message
        self.code = code or self.__class__.__name__

    def __str__(self) -> str:
        return f"[{self.code}] {self.message}"


# ── 领域异常 ──────────────────────

class NotFoundError(AppError):
    """资源不存在"""
    pass

class UserNotFoundError(NotFoundError):
    def __init__(self, user_id: int) -> None:
        super().__init__(f"User {user_id} not found")
        self.user_id = user_id

class ValidationError(AppError):
    """输入数据验证失败"""
    def __init__(self, field: str, reason: str) -> None:
        super().__init__(f"Validation failed for '{field}': {reason}")
        self.field = field
        self.reason = reason

class DuplicateError(AppError):
    """唯一性冲突"""
    pass

class DuplicateEmailError(DuplicateError):
    def __init__(self, email: str) -> None:
        super().__init__(f"Email '{email}' already exists")
        self.email = email

class PermissionError(AppError):
    """权限不足"""
    pass

class ExternalServiceError(AppError):
    """外部服务调用失败"""
    def __init__(self, service: str, reason: str) -> None:
        super().__init__(f"External service '{service}' failed: {reason}")
        self.service = service
```

---

## 正确的捕获模式

### ❌ 不要这样做

```python
# 吞掉异常（最危险）
try:
    result = do_something()
except:
    pass

# 裸 except（捕获所有，包括 KeyboardInterrupt）
try:
    result = do_something()
except Exception:
    print("Something went wrong")

# 捕获了但没有处理
try:
    result = do_something()
except ValueError:
    pass  # 静默失败
```

### ✅ 正确模式

```python
import logging

logger = logging.getLogger(__name__)

# 1. 捕获具体异常，记录并重新抛出
def get_user(user_id: int) -> User:
    try:
        return user_repo.get(user_id)
    except DatabaseConnectionError as e:
        logger.error("DB connection failed while getting user %d: %s", user_id, e)
        raise ExternalServiceError("database", str(e)) from e

# 2. 捕获并转换异常类型（带 from 保留原始 traceback）
def create_user(email: str) -> User:
    try:
        return user_repo.create(email=email)
    except IntegrityError as e:
        raise DuplicateEmailError(email) from e

# 3. 多个异常分别处理
def process_file(path: str) -> str:
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        raise NotFoundError(f"File not found: {path}")
    except PermissionError:
        raise AppError(f"No permission to read: {path}")
    except OSError as e:
        logger.exception("Unexpected OS error reading %s", path)
        raise
```

---

## 上下文管理器中的异常

```python
from contextlib import contextmanager
from typing import Generator

@contextmanager
def transaction() -> Generator[None, None, None]:
    """数据库事务上下文管理器"""
    try:
        yield
        db.commit()
    except AppError:
        db.rollback()
        raise  # 业务异常向上传播
    except Exception as e:
        db.rollback()
        logger.exception("Unexpected error in transaction")
        raise AppError("Transaction failed") from e
```

---

## 异常与 API 层的映射

```python
# FastAPI 示例
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse

async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
    """统一异常处理器，将业务异常映射到 HTTP 状态码"""
    status_code_map = {
        NotFoundError: 404,
        ValidationError: 422,
        DuplicateError: 409,
        PermissionError: 403,
    }
    status_code = 500
    for exc_type, code in status_code_map.items():
        if isinstance(exc, exc_type):
            status_code = code
            break

    return JSONResponse(
        status_code=status_code,
        content={"error": exc.code, "message": exc.message}
    )

# 注册异常处理器
app.add_exception_handler(AppError, app_error_handler)
```

---

## 测试异常

```python
import pytest
from myapp.exceptions import UserNotFoundError, DuplicateEmailError

class TestUserServiceErrors:
    def test_get_nonexistent_user_raises(self, user_service):
        with pytest.raises(UserNotFoundError) as exc_info:
            user_service.get_user(user_id=99999)

        # 验证异常的附加信息
        assert exc_info.value.user_id == 99999

    def test_duplicate_email_raises(self, user_service, existing_user):
        with pytest.raises(DuplicateEmailError) as exc_info:
            user_service.create_user(email=existing_user.email)

        assert existing_user.email in str(exc_info.value)
```

---

## Logging 最佳实践

```python
import logging

# ✅ 每个模块用自己的 logger
logger = logging.getLogger(__name__)  # 会是 "myapp.services.user_service"

# ✅ 使用 % 格式（懒求值，性能更好）
logger.info("Processing user %d", user_id)

# ❌ 不要用 f-string（即使 log level 没启用也会计算）
logger.info(f"Processing user {user_id}")

# ✅ 异常 logging 用 exception（自动附加 traceback）
try:
    risky_operation()
except Exception:
    logger.exception("Failed to perform risky operation")
    raise

# ✅ 预期的业务异常用 warning，非预期的用 error/exception
logger.warning("User %d not found, returning None", user_id)  # 业务预期
logger.error("Database connection failed: %s", e)              # 非预期
```

---

## 异常设计 Checklist

- [ ] 所有业务异常继承 `AppError`
- [ ] 异常信息包含足够上下文（ID、值等）
- [ ] 异常捕获时用 `raise X from e`（保留 cause）
- [ ] 不吞掉异常（除非有充分理由且记录 warning）
- [ ] API 层有统一异常映射
- [ ] 测试覆盖所有自定义异常路径
