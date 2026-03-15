# UV 常见问题与修复

## 快速诊断清单

```bash
# 1. 检查 uv 是否安装
uv --version

# 2. 检查 Python 版本是否符合 pyproject.toml
uv run python --version

# 3. 检查依赖是否同步
uv sync   # 重新同步，幂等操作

# 4. 查看依赖树（排查版本冲突）
uv tree
```

---

## 常见错误与修复

### ❌ `uv: command not found`

**原因：** uv 未安装。

**修复：**
```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# 或者用 Homebrew（macOS）
brew install uv

# 安装后重新加载 shell
source ~/.zshrc  # 或 source ~/.bashrc
```

---

### ❌ `ModuleNotFoundError: No module named 'xxx'`

**原因：** 忘记运行 `uv sync`，或者用了全局 Python 而不是 `uv run`。

**修复：**
```bash
# 步骤 1：同步依赖
uv sync

# 步骤 2：确保用 uv run 运行
uv run python script.py   # ✅
python script.py           # ❌（可能用了错误的 Python）
```

---

### ❌ `No pyproject.toml found`

**原因：** 在错误的目录运行了命令，或者项目还没初始化。

**修复：**
```bash
# 确认在项目根目录
ls pyproject.toml

# 如果是新项目，初始化
uv init .       # 在当前目录初始化（不创建子目录）
```

---

### ❌ `error: Resolution failed` / 依赖冲突

**原因：** 依赖之间版本互相冲突。

**修复：**
```bash
# 查看冲突原因
uv tree

# 尝试放宽版本约束（在 pyproject.toml 里修改）
# 例如：把 "fastapi==0.100.0" 改为 "fastapi>=0.100"

# 解锁并重新解析
uv lock --upgrade
uv sync
```

---

### ❌ `ruff: command not found`（在 hook 里）

**原因：** Hook 没有走 `uv run`，ruff 未全局安装。

**这正是为什么必须用 `uv run ruff` 而不是裸 `ruff`。**

**正确做法：**
```bash
uv run ruff check .   # ✅ 用项目 venv 里的 ruff
ruff check .           # ❌ 依赖全局安装，不可靠
```

---

### ❌ pytest 找不到模块（src layout）

**原因：** 项目用了 `src/` 布局，但包没有被安装。

**修复：**
```bash
# 确保 pyproject.toml 有构建系统配置
# 然后 uv sync 会自动以 editable 模式安装
uv sync

# 验证
uv run python -c "import my_package; print('OK')"
```

确认 `pyproject.toml` 包含：
```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

---

### ❌ Python 版本不匹配

**原因：** 系统 Python 版本和 `pyproject.toml` 里的 `requires-python` 不符。

**修复：**
```bash
# 查看可用 Python 版本
uv python list

# 安装特定版本
uv python install 3.11

# 锁定项目 Python 版本
uv python pin 3.11

# 重新同步
uv sync
```

---

### ❌ `.venv` 损坏 / 奇怪行为

**修复：**
```bash
# 删除并重建 venv（终极方案）
rm -rf .venv
uv sync
```

---

### ❌ `mypy` 找不到类型存根

**原因：** 某些第三方库没有类型存根（stubs）。

**修复：**
```bash
# 安装对应的 stub 包
uv add --dev types-requests types-PyYAML types-Pillow

# 或者在 pyproject.toml 里全局忽略
```

```toml
[tool.mypy]
ignore_missing_imports = true   # 忽略所有缺失 stubs（宽松）

# 更精细的控制
[[tool.mypy.overrides]]
module = ["gradio.*", "pandas.*"]
ignore_missing_imports = true
```

---

## 环境重置步骤（万能方案）

```bash
# 1. 删除 venv
rm -rf .venv

# 2. 清除 uv 缓存（可选，当怀疑缓存有问题时）
uv cache clean

# 3. 重新安装
uv sync

# 4. 验证
uv run python --version
uv run pytest --co -q  # 列出测试，验证导入正常
```
