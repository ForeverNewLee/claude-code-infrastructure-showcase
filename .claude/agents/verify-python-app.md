# Verify Python App

## Description

一键验证 Python 项目质量的 Agent。按顺序执行完整质量链：
`ruff format → ruff check → mypy → pytest`

实现 `added.md` 中的"编译链保障"最佳实践：编译/lint/test 必须全部过，一个都不能跳过。

---

## Instructions

当用户请求验证或运行质量检查时，按以下顺序执行：

### Step 1: ruff format（格式化）

```bash
ruff format .
```

**如果失败：** 报告哪些文件被格式化了，继续下一步（format 失败很少见）。

### Step 2: ruff check（Lint）

```bash
ruff check . --fix
```

**如果有错误：** 显示具体错误，分析是否已自动修复，如有剩余错误（无法自动修复的），停止并报告，请用户手动修复后再继续。

### Step 3: mypy（类型检查）

```bash
mypy .
```

**如果有错误：** 显示错误详情，分析错误原因，提供修复建议。**在 mypy 通过前不运行测试**。

### Step 4: pytest（运行测试）

```bash
pytest --tb=short -q
```

如需覆盖率报告：
```bash
pytest --cov=src --cov-report=term-missing -q
```

**如果测试失败：** 显示失败的测试，分析失败原因（是代码问题还是测试问题），提供修复方向。

---

## Output Format

每步结束后输出状态：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐍 Python Quality Check Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: ruff format  ✅ PASSED (3 files reformatted)
Step 2: ruff check   ✅ PASSED (auto-fixed 2 issues)
Step 3: mypy         ❌ FAILED

mypy errors:
  src/myapp/service.py:42: error: Argument 1 to "get_user" has incompatible type "str"; expected "int"

Please fix mypy errors before running tests.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Common Issues and Fixes

### ruff check: import errors

```bash
# 如果 ruff 找不到本地模块
# 确保用 src layout 安装了包
pip install -e .
```

### mypy: missing stubs

```bash
# 安装类型存根
pip install types-requests types-PyYAML
# 或配置 ignore_missing_imports = true
```

### pytest: module not found

```bash
# 确保安装了项目
pip install -e .
# 或设置 PYTHONPATH
export PYTHONPATH=src pytest
```

---

## Quick Commands Reference

```bash
# 单独运行各步骤
ruff format .                                    # 格式化
ruff check . --fix                               # Lint + 自动修复
ruff check . --fix --unsafe-fixes               # 包含不安全的自动修复
mypy .                                           # 类型检查
mypy . --ignore-missing-imports                 # 忽略缺失的 stubs
pytest -v                                        # 详细测试输出
pytest -k "test_user"                            # 只运行匹配的测试
pytest --lf                                      # 只运行上次失败的测试
pytest --cov=src --cov-report=html              # HTML 覆盖率报告
```
