# Commit Examples — Conventional Commits 实例

## 按类型的好 Commit 示例

### feat — 新功能

```bash
# 简单功能
feat(api): add GET /items/{id} endpoint

# 带 body（说明 WHY）
feat(service): add result caching with TTL

Cache frequently requested data to reduce repeated computation.
Default TTL is 5 minutes, configurable via settings.cache_ttl.

# Gradio 功能
feat(ui): add file upload support for batch processing

# Breaking change
feat(api)!: change response schema to wrap data in {data: ...}

BREAKING CHANGE: All endpoints now return {"data": ..., "meta": ...}
Update all API consumers to unwrap the data field.
```

### fix — Bug 修复

```bash
# 具体修复
fix(api): return 422 instead of 500 for invalid date format

fix(ui): handle None return from service in Gradio output component

fix(service): prevent division by zero in percentage calculation

# 修复 + 影响说明
fix(config): load .env before creating settings instance

Previously settings was instantiated at import time before .env was loaded,
causing environment variables to be ignored in some deployment scenarios.
```

### refactor — 重构

```bash
refactor(service): extract data validation into separate validator class

refactor(api): consolidate error handling into middleware

refactor: replace manual type checks with isinstance guards
```

### test — 测试

```bash
test(api): add missing 404 case for GET /items/{id}

test(service): add parametrized tests for edge cases in parser

test: add integration test for full request lifecycle
```

### chore — 构建/依赖

```bash
chore(deps): add pandas for data processing support

chore(deps): upgrade gradio from 4.x to 5.x

chore: configure ruff with stricter rules (B, SIM rules)

chore(ci): add mypy check to GitHub Actions workflow
```

### docs — 文档

```bash
docs: add API endpoint documentation to README

docs(api): add docstrings to all route handlers

docs: update CLAUDE.md with new quality check commands
```

### perf — 性能

```bash
perf(service): add lru_cache to expensive computation function

perf(api): add response compression middleware
```

---

## Commit Message 写法技巧

### 标题（Header）原则

1. **动词用祈使句（Imperative mood）**
   - ✅ `add search endpoint`
   - ❌ `added search endpoint` / `adding search endpoint`

2. **描述 WHAT，不描述 HOW**
   - ✅ `add pagination to item list`
   - ❌ `add offset and limit parameters to SQL query`

3. **50 字符以内**（GitHub 显示截断位置）

### Body 原则

写 Body 的时机：
- 原因不从代码中显而易见
- 有重要的背景信息
- 有 trade-off 需要解释

```
feat(service): use batch API calls instead of sequential

Sequential calls were timing out for lists > 100 items.
Batch processing reduces API calls from N to ceil(N/50),
cutting average response time from 30s to 2s.
```

---

## 常见 Anti-Patterns

| 差的 commit | 问题 | 改进 |
|------------|------|------|
| `fix bug` | 完全不知道修了什么 | `fix(api): handle None user_id in auth middleware` |
| `WIP` | 临时状态不应提交 | 用 `git stash` 或 feature branch |
| `changes` | 无信息 | 具体说明做了什么 |
| `update service.py` | 说文件名不说内容 | `refactor(service): extract validation logic` |
| `feat: add stuff` | scope 缺失 + 描述模糊 | `feat(ui): add language selector dropdown` |

---

## 多文件变更的拆分策略

**一次 commit 做一件事**：

```bash
# ❌ 一个 commit 混了多件事
# "add search + fix auth bug + update deps"

# ✅ 拆成 3 个 commit
git add src/api/routes/search.py tests/api/test_search.py
git commit -m "feat(api): add item search with keyword filter"

git add src/api/middleware/auth.py
git commit -m "fix(api): correctly validate expired JWT tokens"

git add pyproject.toml uv.lock
git commit -m "chore(deps): upgrade httpx to 0.27"
```
