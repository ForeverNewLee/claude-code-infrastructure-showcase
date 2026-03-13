# Run Quality Checks

将 Python 项目的完整质量链按顺序执行：`ruff format → ruff check → mypy → pytest`

每一步失败就停止，避免在有问题的代码上继续跑测试。

## Instructions

1. 首先，检查当前目录是否有 `pyproject.toml`：
   ```bash
   ls pyproject.toml
   ```

2. 按以下顺序运行命令（任一失败则停止并报告）：

```bash
# Step 1: Format
ruff format .

# Step 2: Lint + auto-fix
ruff check . --fix

# Step 3: Type check
mypy .

# Step 4: Tests
pytest --tb=short -q
```

3. 汇总结果，格式化输出每步是否通过。

4. 如果全部通过，提示可以提交了：
   "✅ All checks passed! Ready to commit."

5. 如果有失败，分析失败原因并提供修复建议（但不要自动修复——让用户决定）。

## Quick All-in-One

如果只需要快速运行，可以直接执行：

```bash
ruff format . && ruff check . --fix && mypy . && pytest
```
