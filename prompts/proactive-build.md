# 主动建设：会话末复盘、提炼、升级、修剪

`maintain.md` 讲的是被动触发时怎么写一篇。本文件讲 agent 主动维护记忆库的四件事。

## 1. 会话末复盘（每次较长会话结束前）

按顺序回答下面的问题，每个「是」对应一次 `mem add` 或一次编辑：

1. 这次会话产出了什么**可复用的结果**？（脚本、命令、配置、流程）
2. 有没有花了超过 10 分钟才查明的**原因**？把原因和诊断路径写下来。
3. 用户有没有**纠正**我？原话大意是什么？以后的规则是什么？
4. 做了什么**决策**？放弃了哪个方案，为什么？
5. 有没有读到的记忆**与现场不符**？标记过期。
6. 有没有我**以为记忆里有、结果没有**的东西？补上。

做完跑 `mem build`，在回复用户时用一行列出新增/修改的 note 名。没有可写的就不写，不硬凑。

## 2. 提炼：episode → 决策 → 坑

原始经历（episode）价值最低，提炼后的规则价值最高。写的时候往上提一层：

| 层级 | 例 | 放在哪 |
|---|---|---|
| episode | 「今天部署后服务没变，查了 40 分钟发现进程没重启」 | FACT 节，一两行 |
| 决策 | 「上线 = release + restart，两步都要跑」 | 决策／结论节 |
| 坑 | 「验收看进程 cwd，不看软链接」 | 坑节，并写进 description |

如果同一个坑在 3 篇以上 note 里出现，新建一篇 `--type feedback` 或 `--type reference` 的总结 note，description 写规则本身，「相关」里链接那几篇。必要时建议用户把这条规则提升进 AGENTS.md / CLAUDE.md。

## 3. 升级为 pack

pack 是 `packs.json` 里定义的领域，不是手写的文件。出现以下信号时，建议新开 pack：

- `mem build` 的 `unclassified` 持续增长，`mem ls misc` 里能看出一个主题聚了 5 篇以上。
- 某个 pack 超出 `pack_budget_bytes`，里面明显是两个主题。

操作：

1. `mem ls misc` 或 `mem ls <大 pack>`，列出候选。
2. 在 `$MEM_HOME/.memorypack/packs.json` 的 `packs` 数组加一项：

   ```json
   {
     "id": "billing",
     "title": "计费／账单",
     "read_when": "碰扣费、额度、发票时",
     "strong": ["计费", "billing"],
     "keywords": ["invoice", "额度", "quota", "退款"]
   }
   ```

   - `strong`（+3）放只在这个领域出现的词；`keywords`（+1）放常见但相关的词。
   - 不要放 note 模板里的固定小节名（FACT、决策、坑、相关），否则所有 note 都会被拉进来。
   - 数组顺序就是 MEMORY.md 里的展示顺序，也是同分时的优先顺序。
3. `mem build`，`mem ls <新 id>` 检查分得对不对；个别分错的 note 在 front-matter 写 `metadata.pack` 钉住。
4. 修改 `packs.json` 属于改配置，先告诉用户改了什么。

## 4. 修剪 Tier-0 预算

`MEMORY.md` 被设计成每次会话都整篇读，所以它有字节上限 `router_budget_bytes`（默认 12000）。超预算时按顺序处理：

1. 缩短 `packs.json` 里各 pack 的 `read_when`（每条控制在 40 字以内）。
2. 下调 `hot_count`（热档条数，默认 12）。
3. 缩短热档里那几篇 note 的 description（热档会截到 180 字）。
4. 合并内容重叠的 pack，减少路由表行数。

不要通过手改 `MEMORY.md` 来压缩，下次 build 会还原。

## 5. 定期体检

每周或每 ~50 篇新 note：

```bash
mem doctor          # 预算、断链、缺 description、误写的索引文件
mem ls              # 各 pack 条目数，看分布是否失衡
mem ls misc         # 未分类里有没有可以成 pack 的主题
```
