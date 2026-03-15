# Run Quality Checks

将 Python 项目的完整质量链按顺序执行：`ruff format → ruff check → mypy → pytest`

每一步失败就停止，避免在有问题的代码上继续跑测试。

> ⚠️ 所有命令通过 `uv run` 执行，确保使用项目 venv 里的正确版本。

## Instructions

1. **检查环境就绪**：

   ```bash
   # 确认 pyproject.toml 存在
   ls pyproject.toml

   # 确认 uv.lock 存在且 venv 已同步
   ls uv.lock
   ```

   - 如果 `pyproject.toml` 不存在：停止并提示用户先初始化项目（`uv init .`）
   - 如果 `uv.lock` 不存在 或 用户刚更新了依赖：先运行 `uv sync`

2. **按以下顺序运行命令（任一失败则停止并报告）：**

   ```bash
   # Step 1: Format
   uv run ruff format .

   # Step 2: Lint + auto-fix
   uv run ruff check . --fix

   # Step 3: Type check
   uv run mypy .

   # Step 4: Tests
   uv run pytest --tb=short -q
   ```

3. 汇总结果，格式化输出每步是否通过。

4. 如果全部通过，提示可以提交了：
   "✅ All checks passed! Ready to commit."

5. 如果有失败，分析失败原因并提供修复建议（但不要自动修复——让用户决定）。

## Quick All-in-One

如果只需要快速运行，可以直接执行：

```bash
uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest
```
