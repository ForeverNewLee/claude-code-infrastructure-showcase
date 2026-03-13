---
name: git-workflow
description: Git 工作流与提交规范技能。当准备提交代码、编写 commit message、创建 PR、管理分支，或需要了解 Conventional Commits 格式时激活。涵盖 Conventional Commits 规范、commit message 写法、分支命名、PR 模板、提交前检查。
---

# Git Workflow

## 核心规范：Conventional Commits

所有 commit 都必须遵循 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>(<scope>): <简短描述>

[可选 body：说明 WHY，不是 WHAT]

[可选 footer：Breaking changes, Issue refs]
```

---

## Commit 类型（type）

| 类型 | 用途 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(api): add search endpoint` |
| `fix` | Bug 修复 | `fix(ui): correct output type error` |
| `refactor` | 重构（不改行为） | `refactor(service): extract parser` |
| `test` | 添加/修改测试 | `test(api): add edge cases for auth` |
| `docs` | 文档更新 | `docs: update API README` |
| `chore` | 构建/依赖/工具 | `chore: update ruff to 0.4` |
| `perf` | 性能优化 | `perf(query): add index on user_id` |
| `ci` | CI/CD 变更 | `ci: add mypy check to pipeline` |
| `style` | 纯格式（不改逻辑） | `style: reformat config module` |

---

## Scope（范围）

根据项目层次选择 scope：

| Scope | 适用场景 |
|-------|---------|
| `api` | FastAPI 路由、端点 |
| `ui` | Gradio 界面 |
| `service` | 业务逻辑层 |
| `model` | Pydantic 模型、数据结构 |
| `config` | 配置、环境变量 |
| `deps` | 依赖变更（uv add/remove） |
| `test` | 测试文件 |

scope 可以省略，但有 scope 的 commit 信息更清晰。

---

## 好的 vs 差的 Commit Message

```bash
# ❌ 差：模糊，看不出做了什么
git commit -m "fix bug"
git commit -m "update"
git commit -m "wip"
git commit -m "changes"

# ✅ 好：类型明确，描述具体
git commit -m "feat(api): add paginated item list endpoint"
git commit -m "fix(ui): handle empty response in gradio output"
git commit -m "test(service): add missing edge cases for data parser"
git commit -m "chore(deps): add httpx for async http client"
```

---

## Breaking Changes

涉及破坏性变更时，在 commit 加 `!` 或 footer：

```bash
# 方式 1：类型后加 !
feat(api)!: change response schema for /items endpoint

# 方式 2：footer 详细说明
feat(api): rename user_id to userId in all responses

BREAKING CHANGE: All responses now use camelCase.
Clients must update their parsers.
```

---

## 分支命名规范

```
<type>/<short-description>

feat/item-search-pagination
fix/gradio-output-type
refactor/service-layer-cleanup
test/api-auth-edge-cases
chore/update-deps-march
```

---

## 提交前 Checklist

```bash
# 1. 查看变更
git diff --stat
git status

# 2. 质量链（必须全过）
uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest

# 3. 只暂存需要的文件
git add src/myapp/service.py tests/test_service.py
# (不要 git add . 除非确认所有文件都要提交)

# 4. 检查暂存内容
git diff --staged

# 5. 提交
git commit -m "feat(service): add data validation layer"
```

---

## 快速导航

| 需要了解... | 读这个 |
|------------|--------|
| commit message 更多示例 | [commit-examples.md](resources/commit-examples.md) |
| PR 模板与 Review 流程 | [pr-workflow.md](resources/pr-workflow.md) |
| 撤销与修复 commit | [git-recovery.md](resources/git-recovery.md) |

---

**Skill Status**: COMPLETE ✅
