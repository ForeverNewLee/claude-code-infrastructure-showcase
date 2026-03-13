# Commit, Push, and Create PR

提交前完整流程：状态检查 → 质量链 → Conventional Commits message 生成 → 推送 → PR。

## Instructions

### Step 1: 自查 git 状态

```bash
git status --short
git diff --stat
```

**分析输出：**
- 有未暂存文件？询问用户是否全部暂存，还是只暂存特定文件
- 有 `.env`、`.pyc`、`__pycache__` 等不应提交的文件？警告用户排除
- 暂存区已有内容？直接使用，跳过 add 步骤

### Step 2: 快速质量检查（提交门禁）

```bash
uv run ruff check . && uv run mypy . && uv run pytest -q --tb=no
```

❌ **任一失败：停止**，告知用户具体失败原因，**不继续提交**。
✅ **全部通过：继续**。

### Step 3: 分析变更，生成 Conventional Commits message

读取暂存内容：
```bash
git diff --staged --stat
git diff --staged
```

**按以下规则生成 commit message：**

```
<type>(<scope>): <简短描述（祈使句，<50字符）>

[可选 body：解释 WHY，不是 WHAT]
```

**类型选择：**
| 变更内容 | type |
|---------|------|
| 新功能、新端点、新组件 | `feat` |
| Bug 修复 | `fix` |
| 重构（不改行为） | `refactor` |
| 新增/修改测试 | `test` |
| 文档更新 | `docs` |
| 依赖变更（uv add/remove） | `chore(deps)` |
| 配置/构建/工具 | `chore` |
| 性能优化 | `perf` |

**Scope 参考（根据项目层次）：**
`api` | `ui` | `service` | `model` | `config` | `deps` | `test`

**好的 message 示例：**
```bash
feat(api): add paginated search endpoint for items
fix(ui): handle empty response in Gradio output component
refactor(service): extract data parser into separate class
test(api): add edge cases for invalid auth token
chore(deps): add pandas for data processing
```

**展示生成的 message，等用户确认或修改。**

### Step 4: 暂存 + 提交

```bash
# 如果需要暂存
git add <files>  # 精确指定，不要 git add . 除非确认

# 提交
git commit -m "<confirmed message>"
```

### Step 5: Push

```bash
# 检查当前分支
git branch --show-current

# 推送
git push origin HEAD
```

如果是新分支（提示设置上游）：
```bash
git push --set-upstream origin <branch-name>
```

### Step 6: 创建 PR

```bash
# 检测是否有 gh CLI
which gh && gh auth status
```

**有 gh CLI：**
```bash
gh pr create \
  --title "<commit message 标题>" \
  --body "## 变更摘要

$(git log main..HEAD --oneline)

## 测试
- [ ] 质量链全部通过（ruff + mypy + pytest）
- [ ] 手动验证关键功能" \
  --draft
```

**无 gh CLI：** 输出 PR 链接：
```
请在浏览器打开：
https://github.com/<owner>/<repo>/compare/<branch>
```

### 完成摘要

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 质量检查：全部通过
✅ 提交：feat(api): add search endpoint
✅ 推送：origin/feat/item-search
✅ PR：https://github.com/...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
