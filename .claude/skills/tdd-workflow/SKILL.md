---
name: tdd-workflow
description: TDD (测试驱动开发) 工作流技能。当开始实现新功能、编写测试、做 AI 交叉代码 review，或需要质量验证流程时激活。提供先写测试→再实现→质量链验证的完整工作流。
---

# TDD Workflow

## 核心工作流（3步）

```
① 先写测试  →  ② 实现功能  →  ③ 质量链验证
   (AI 写)        (AI 写)       ruff + mypy + pytest
```

> **黄金法则：AI 生成的代码，未经测试都是废品。**

---

## Step 1：Prompt AI 写测试

**模板：**

```
我需要实现 [功能名]，需求是：
- [需求1]
- [需求2]
- 失败时抛 [ExceptionName]

请先只写 pytest 测试（不要实现），覆盖：
1. 正常路径
2. 边界情况
3. 异常路径
```

**验证测试设计：**
- 测试名称清晰表达意图 ✓
- 正常/边界/异常都有覆盖 ✓
- 使用 fixtures 而不是重复 setup ✓

---

## Step 2：Prompt AI 实现功能

```
现在基于上面的测试，帮我实现 [功能名]，让所有测试通过。
要求：
- 完整类型注解
- 自定义异常继承 AppError
- 不要 bare except
```

---

## Step 3：质量链验证

```bash
ruff format . && ruff check . --fix && mypy . && pytest
```

每步必须通过才能继续。

---

## AI 交叉 Review 工作流

**功能完成后开新对话：**

```
这是我刚完成的 [功能名] 变更：

[粘贴 git diff 或关键代码]

请帮我 review：
1. 有没有潜在 bug 或未覆盖的边界？
2. 测试是否充分？
3. 有没有违反 Python 最佳实践？
4. 类型注解是否完整准确？
5. 异常处理是否合理？
```

---

## 快速参考

| 详细主题 | 资源文件 |
|---------|---------|
| pytest 详细用法 | [test-first-patterns.md](resources/test-first-patterns.md) |
| 交叉 review 完整流程 | [cross-review-guide.md](resources/cross-review-guide.md) |

---

**Skill Status**: COMPLETE ✅
