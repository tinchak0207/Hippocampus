---
name: hippocampus
description: 让 agent 吸取教训：踩过的坑写进硬盘，下次不再踩。在开始一个非平凡任务前调用，用 `mem` 查这类任务以前的决策和坑；在犯错被纠正、查明一个问题的原因、或做出一个决定之后调用，用 `mem add` + `mem build` 把教训沉淀下来。Use before starting a task to look up past lessons, and after a mistake, correction, or decision to record the lesson.
---


# Hippocampus：让 agent 吸取教训

踩过的坑写进 `notes/`，`mem build` 编译进索引，下次同类任务开始前先查到上次怎么栽的。CLI 叫 `mem`。

记忆根目录 `$MEM_HOME`（默认 `~/.claude/memory`）。全部是纯文本，`mem build` 从 `notes/` 生成其余三层。

## 何时使用

- 开始一个非平凡任务前：查这件事以前有没有做过、有没有决策或坑。
- 用户提到「上次」「之前说过」「按老规矩」时。
- 派 subagent 前：把相关记忆写进 spec。
- 完成一个可复用的结果、解决一个反复出现的问题、被用户纠正一次之后：写一篇 note。

## 四层模型

| 层 | 文件 | 内容 | 谁写 |
|---|---|---|---|
| Tier-0 | `MEMORY.md` | 路由表：读写协定、pack 列表、最近 12 篇；有字节预算（默认 12000） | `mem build` |
| Tier-1 | `packs/<id>.md` | 每个领域一页，每篇 note 一行 description + 路径 | `mem build` |
| Tier-2 | `catalog.tsv` | 每篇 note 一行：`pack date type name title bytes gist` | `mem build` |
| Tier-3 | `notes/*.md` | 原文，带 YAML front-matter | `mem add` 建文件，你填内容 |

分类规则在 `$MEM_HOME/.memorypack/packs.json`：front-matter 里 `metadata.pack` 写了合法 id 就用它，否则按关键词打分（strong +3，keywords +1），零分进 `misc`。

## 读路径（按顺序，够用就停）

1. 读 `MEMORY.md` 全文（它很小，就是为了被整篇读）。
2. 按「什么时候读」列找到领域 → `mem pack <id>` 扫读该领域。
3. 需要定位具体条目 → `mem find <关键字> [--pack <id>] [--limit N]`，只返回 catalog 行。
4. 只对命中的 1-3 篇 → `mem show <name>` 读原文。

记忆与现场证据（代码、日志、命令输出）冲突时，以现场为准，并告诉用户哪篇记忆过期了。

## 写路径（只有这一条）

```bash
mem add <slug> --type project|feedback|reference [--pack <id>] [--title "标题"]
# 打开打印出的路径，填 description 一行 + FACT / 决策 / 坑 / 相关
mem build
```

- `description` 是唯一会出现在上三层的内容，写成「这是什么 + 什么时候要用」的一句话。
- 改已有 note：直接编辑 `notes/` 里那一篇，然后 `mem build`。
- 写完可以跑 `mem doctor` 检查预算、断链、缺 description。

## 禁令

- 不手改 `MEMORY.md`、`packs/*`、`catalog.tsv`：它们是生成物，下次 build 会被覆盖。
- 不批量读 `notes/`（`cat notes/*`、`ls` 后逐篇读、对整个目录 grep 原文）：用 `mem find`。
- 不删除 note，除非用户明确要求；过期就在原文标注并更新 description。
- 不把 secret、token、密码、私钥、个人身份信息写进 note。
- 不另开第二个记忆库；其他工具的旧路径用 symlink 指向 `$MEM_HOME`。

## 参考

- 日常维护：`prompts/maintain.md`
- 会话末复盘与主动建设：`prompts/proactive-build.md`
- 可粘贴进 AGENTS.md / CLAUDE.md 的规则段：`prompts/agents-snippet.md`
- hooks 示例：`prompts/hooks/`
