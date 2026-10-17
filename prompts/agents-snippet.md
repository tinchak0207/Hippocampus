# 可粘贴的规则段

把下面 `---` 之间的内容粘贴进项目的 `AGENTS.md`、`CLAUDE.md` 或等价的规则文件。路径按你的 `MEM_HOME` 修改。

---

## 记忆（mem）

长期记忆只有一个库：`~/.claude/memory/`（`$MEM_HOME`），通过 `mem` CLI 读写。

**读**（开始非平凡任务前）：

1. 读 `~/.claude/memory/MEMORY.md`（Tier-0 路由表，整篇读）。
2. 找到相关领域 → `mem pack <id>`。
3. 定位条目 → `mem find <关键字>`；只对命中的几篇 `mem show <name>`。
4. 记忆与现场证据冲突时，以现场为准，并回报哪篇过期。

**写**（完成可复用结果、解决反复出现的问题、被用户纠正一次之后，当场写）：

```bash
mem add <slug> --type project|feedback|reference [--pack <id>]
# 填 description（一句话：是什么 + 什么时候用）和 FACT / 决策 / 坑
mem build
```

**禁止**：

- 手改 `MEMORY.md`、`packs/*`、`catalog.tsv`（生成物，会被 `mem build` 覆盖）。
- 整目录读取 `notes/`；一律用 `mem find`。
- 删除 note（除非用户明确要求）。
- 把 secret、token、密码、私钥写进记忆。

**派 subagent 时**，spec 必须包含「必读记忆」节：

1. `MEMORY.md` 与相关 `packs/<id>.md` 的路径；
2. 2-5 个用 `mem find` 取到、`mem show` 验证过的 note 名，每个附一句为什么相关；
3. 一句指令：「记忆与现场证据冲突时以现场为准，并在回报中指出冲突」。

---
