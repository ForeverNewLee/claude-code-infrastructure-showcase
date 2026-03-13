# PR 工作流与 Review

## 分支 → PR 完整流程

```
feat/xxx 分支开发完成
    ↓
/run-quality-checks  （本地质量链全通过）
    ↓
/git-stage-review    （确认变更范围）
    ↓
/commit-push-pr      （提交 + 推送 + 创建 PR）
    ↓
等待 Review → 修改 → 合并
```

---

## 创建 PR（gh CLI）

```bash
# Draft PR（还没完全准备好，先让别人看）
gh pr create --title "feat(api): add search endpoint" --draft

# 正式 PR，带完整描述
gh pr create \
  --title "feat(api): add keyword search with pagination" \
  --body "$(cat <<'EOF'
## 变更摘要
新增 `/api/v1/search` 端点，支持关键词模糊搜索和分页。

## 测试
- [x] 单元测试全部通过
- [x] ruff + mypy 通过
- [x] 手动测试 Gradio 界面集成

## 影响范围
仅新增，不修改现有接口。
EOF
)"

# 查看自己的 PR
gh pr list --author @me

# 查看 PR 状态
gh pr status
```

---

## PR 描述模板

```markdown
## 变更摘要
[一句话说清楚做了什么]

## 原因 / 背景
[为什么要做这个变更]

## 实现方式
[关键技术决策，为什么这样做]

## 测试
- [ ] 单元测试通过（pytest）
- [ ] 类型检查通过（mypy）
- [ ] 代码风格通过（ruff）
- [ ] 手动验证：[描述验证步骤]

## 影响范围
- 新增 / 修改 / 删除的接口或行为

## 备注
[破坏性变更 / 需要特别注意的地方]
```

---

## PR Review 礼仪

**给 Reviewer：**
- 每条 comment 说清楚是 blocking（必须改）还是 suggestion（可以考虑）
- 用问句而不是命令句："这里为什么用 list 而不是 set？" 而不是 "改成 set"

**给 Author：**
- 所有 comment 都回复（即使是"已修复"或"保持不变，原因是…"）
- 批量改完后 re-request review，不要逐条 ping

---

## 合并策略

| 策略 | 适用场景 |
|------|---------|
| `Squash and merge` | 功能分支，把所有 commit 压成一个干净的提交 |
| `Rebase and merge` | 线性历史，commit 本身已经很整洁 |
| `Merge commit` | 需要保留完整分支历史（少用）|

**推荐：Squash and merge**，主分支历史保持 `feat(api): add search endpoint` 这样的单条记录，清晰。

---

## 紧急修复流程

```bash
# 从 main 开 hotfix 分支
git checkout main && git pull
git checkout -b fix/critical-auth-bug

# 修复 + 快速验证
uv run pytest tests/api/test_auth.py -v

# 直接提交，不等完整质量链（紧急情况）
git commit -m "fix(api): prevent token bypass on expired sessions"
git push origin HEAD

# 直接合并（跳过 PR，或走快速 Review）
gh pr create --title "fix(api): prevent token bypass" --label "hotfix"
```
