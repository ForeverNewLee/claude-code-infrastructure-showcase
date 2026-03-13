# Git Stage & Review

提交前的变更审查流程：查看 diff，理解变更范围，选择性暂存。

## Instructions

### Step 1: 了解当前状态

```bash
git status
```

展示所有变更文件（Untracked / Modified / Staged）。

### Step 2: 查看变更摘要

```bash
git diff --stat
```

显示每个文件的增删行数，帮助判断变更范围是否合理（一次 commit 应只做一件事）。

### Step 3: 分析变更，决定拆分方式

根据 Conventional Commits 原则，**一次 commit 只做一件事**。

询问用户：
- "这次变更涉及多个独立功能吗？建议分批提交。"
- "有没有临时的调试代码需要排除？"

**拆分判断标准：**
- 涉及不同 type（feat + fix）→ 必须拆分
- 涉及不同 scope 且不相关 → 建议拆分
- 同一功能的代码 + 测试 → 可以合并提交

### Step 4: 选择性暂存

```bash
# 暂存特定文件
git add src/myapp/api/routes/items.py tests/api/test_items.py

# 暂存特定文件的部分变更（交互式）
git add -p src/myapp/service.py

# 暂存所有变更（谨慎使用）
git add .
```

### Step 5: 验证暂存内容

```bash
git diff --staged
```

确认暂存的内容正确，没有多余文件（如 `.env`、临时脚本等）。

### Step 6: 输出建议的 commit message

基于暂存内容，按 Conventional Commits 格式生成建议：

```
建议的 commit message：
  feat(api): add paginated item list endpoint

  理由：新增了 GET /items 路由，支持 page/size 参数
  影响文件：routes/items.py, test_items.py
```

询问用户是否接受或修改，然后执行 `/commit-push-pr`。

---

## 快速命令参考

```bash
git status                   # 查看状态
git diff                     # 查看未暂存的变更
git diff --staged            # 查看已暂存的变更
git diff --stat              # 文件级变更摘要
git add <file>               # 暂存文件
git add -p <file>            # 交互式暂存部分变更
git restore --staged <file>  # 取消暂存
git stash                    # 临时保存未完成的工作
```
