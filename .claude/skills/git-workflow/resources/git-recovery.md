# Git 撤销与恢复

常用的"后悔药"命令，按场景分类。

---

## 撤销最后一次 commit（未推送）

```bash
# 撤销 commit，保留改动在暂存区
git reset --soft HEAD~1

# 撤销 commit，保留改动在工作区（未暂存）
git reset HEAD~1

# 撤销 commit，丢弃所有改动（危险！）
git reset --hard HEAD~1
```

---

## 修改最后一次 commit（未推送）

```bash
# 修改 commit message
git commit --amend -m "fix(api): correct error handling for 404"

# 追加文件到最后一次 commit（不改 message）
git add forgotten_file.py
git commit --amend --no-edit
```

---

## 撤销已推送的 commit

```bash
# 生成一个"反向 commit"（推荐，安全）
git revert <commit-hash>
git push

# 强制重写历史（危险！只在个人分支用）
git reset --hard <commit-hash>
git push --force-with-lease  # 比 --force 安全
```

---

## 恢复误删的文件

```bash
# 恢复工作区中被删除但未暂存的文件
git restore <file>

# 恢复已暂存的删除
git restore --staged <file>
git restore <file>

# 从某个 commit 恢复文件
git checkout <commit-hash> -- <file>
```

---

## 暂存当前工作（去处理其他事）

```bash
# 保存当前未提交的工作
git stash

# 保存时加描述
git stash push -m "WIP: search feature pagination"

# 查看所有 stash
git stash list

# 恢复最近一次 stash
git stash pop

# 恢复指定 stash
git stash apply stash@{2}
```

---

## 误操作后找回（reflog）

```bash
# 查看所有操作历史（包括已删除的 commit）
git reflog

# 找到目标 commit hash 后恢复
git checkout <hash>          # 临时查看
git reset --hard <hash>      # 恢复到该状态
git cherry-pick <hash>       # 只挑出该 commit
```

---

## commit 提交了错误文件

```bash
# 从暂存区移除文件（保留本地文件）
git rm --cached .env
git commit --amend --no-edit

# 同时加入 .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit --amend --no-edit
```

---

## 快速查看历史

```bash
# 简洁的单行历史
git log --oneline -10

# 带分支图
git log --oneline --graph --all -15

# 某个文件的修改历史
git log --oneline -- src/myapp/service.py

# 两个分支之间的差异
git log main..feat/search --oneline
```
