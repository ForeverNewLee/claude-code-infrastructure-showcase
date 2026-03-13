# Claude Code 基础设施指南

这个 `.claude/` 目录是 Claude Code 的基础设施层，为 Python（FastAPI + Gradio）项目提供自动化工具链。

---

## 目录结构

```
.claude/
├── agents/      # 专职子代理（手动召唤）
├── commands/    # 斜杠命令（手动触发）
├── hooks/       # 自动化钩子（全自动，无需操心）
├── skills/      # 知识规范库（自动激活）
└── settings.json
```

---

## 🪝 Hooks — 全自动，你不用做任何事

Hooks 是整个系统的"发动机"，在特定时机自动执行，**跟你说什么无关**。

| Hook | 触发时机 | 做什么 |
|------|---------|--------|
| `skill-activation-prompt.sh` | 你每次发消息 | 分析你的意图，自动推送相关 Skill 给 Claude |
| `post-tool-use-python.sh` | Claude 每次写完 `.py` 文件 | 自动运行 `ruff format` + `ruff check --fix` |

**效果**：Claude 写完代码 → 代码立刻被格式化 → Claude 知道规范并遵循 → 你什么都没做。

---

## 🎨 Skills — 知识规范库，自动激活

Skills 是 Claude 的"项目规范手册"，Hook 分析你的消息后自动把相关 Skill 推给 Claude，Claude 读完就会遵循里面的规范。

| Skill | 激活条件 | 提供什么 |
|-------|---------|---------|
| `python-dev-guidelines/` | 说任何 Python/FastAPI/Gradio/ruff/mypy 相关的话，或编辑 `.py` 文件 | 类型注解规范、异常设计、项目结构、ruff/mypy 配置 |
| `tdd-workflow/` | 说"先写测试"、"TDD"、"交叉 review" | TDD 流程模板、测试 Prompt 库、交叉 review 指南 |
| `git-workflow/` | 说"commit"、"提交"、"PR"、"分支" | Conventional Commits 规范、commit 示例、PR 流程、Git 后悔药 |
| `skill-developer/` | 说"创建新技能"、"写 skill" | 如何创建和配置新的 Skill |

> **Skills 本身不执行任何操作**，它们只是给 Claude 看的规范文档。

---

## 💬 Commands — 斜杠命令，手动触发多步任务

在 Claude Code 对话里输入 `/命令名` 触发，把多步骤操作压缩为一条指令。

| 命令 | 做什么 | 什么时候用 |
|------|--------|-----------|
| `/run-quality-checks` | 依次跑 `ruff → mypy → pytest`，任一失败停止 | 功能完成后验证 |
| `/git-stage-review` | 查看 diff、判断是否拆分 commit、生成 commit message 草稿 | 提交前审查变更 |
| `/commit-push-pr` | 质量检查 → 生成 Conventional Commits message → push → 创建 PR | 正式提交 |
| `/dev-docs` | 为当前任务生成 plan/context/tasks 三件套文档 | 开始复杂功能前 |
| `/dev-docs-update` | 更新已有的任务文档 | 长对话快结束时保存进度 |

---

## 🤖 Agents — 专职子代理，手动召唤

用 `/agent 名称` 在 Claude Code 里召唤。每个 Agent 是一个独立的 Claude 子实例，只负责一件事，拥有独立上下文，不受当前对话干扰。

### Python 专属

| Agent | 做什么 | 什么时候用 |
|-------|--------|-----------|
| `python-tdd-assistant` | 引导 TDD：先只输出测试，确认后再输出实现 | 开始写新功能 |
| `python-code-reviewer` | 交叉 Code Review，输出 Critical/Quality/Test/Suggestion 四级报告 | 功能完成后 Review |
| `verify-python-app` | 运行完整质量链，分析失败原因并给出修复建议 | 需要诊断质量问题时 |

### 通用

| Agent | 做什么 | 什么时候用 |
|-------|--------|-----------|
| `code-architecture-reviewer` | 从架构角度审查模块设计 | 新模块完成后评估设计 |
| `code-refactor-master` | 规划并执行重构 | 需要重构某个模块 |
| `refactor-planner` | 只出重构方案，不动代码 | 大型重构前规划 |
| `documentation-architect` | 系统分析代码，生成开发者文档 | 需要写文档时 |
| `plan-reviewer` | 深度评审开发方案（用 Opus 模型） | 实现前验证设计 |
| `web-research-specialist` | 搜索技术问题，综合多方来源 | 遇到不熟悉的技术问题 |

---

## 真实工作流

### 日常功能开发

```
1. 开分支：git checkout -b feat/xxx

2. 说需求给 Claude
   └─ Hook 自动推 python-dev-guidelines
   └─ Claude 按规范写代码

3. 召唤 TDD 助手：/agent python-tdd-assistant
   └─ 先生成测试 → 确认 → 生成实现

4. Claude 写代码时 Hook 自动格式化（你什么都不用做）

5. 验证质量：/run-quality-checks
   └─ 有失败 → Claude 修 → 再跑

6. 交叉 Review：/agent python-code-reviewer
   └─ 把代码给它 → 修复 review 指出的问题

7. 提交：/git-stage-review → /commit-push-pr
```

### 复杂功能 / 多轮对话

```
1. 开始前生成任务文档：/dev-docs
   └─ 生成 plan/context/tasks，防止 context 丢失

2. 实现前验证方案：/agent plan-reviewer
   └─ 避免走弯路

3. 开发过程同"日常功能开发"

4. 快结束时更新文档：/dev-docs-update
   └─ 保存决策记录，方便开新对话继续
```

### 遇到技术问题

```
/agent web-research-specialist
└─ 描述问题，它去搜 GitHub Issues / Stack Overflow 汇总结论
```

---

## settings.json

注册 Hooks 的入口文件，复制到新项目时**必须包含**，否则 Hooks 不会自动运行。

```json
{
  "hooks": {
    "UserPromptSubmit": [skill-activation-prompt.sh],  // 自动推 Skill
    "PostToolUse":      [post-tool-use-python.sh]       // 自动 ruff
  }
}
```

---

## 快速上手新项目

```bash
# 1. 复制整个 .claude/ 目录到新项目
cp -r .claude/ ~/your-project/

# 2. 在新项目根目录创建 CLAUDE.md（参考下方模板）
# 写明：技术栈、质量命令、项目结构、特殊约定

# 3. 安装依赖（uv 推荐）
uv add --dev ruff mypy pytest pytest-asyncio pytest-cov httpx

# 4. 开始开发，其余自动运行
```

**CLAUDE.md 最少要包含：**
- 项目是做什么的（一句话）
- `uv run ruff format . && uv run ruff check . --fix && uv run mypy . && uv run pytest` 质量命令
- 项目主要目录结构
