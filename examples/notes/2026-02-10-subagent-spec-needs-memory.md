---
name: 2026-02-10-subagent-spec-needs-memory
description: 派 subagent 时 spec 必须带「必读记忆」节：MEMORY.md + 相关 pack + 2-5 个 note 名；否则 subagent 会从零考古
metadata:
  type: feedback
  pack: tooling
---

# subagent spec 必须带「必读记忆」节

## FACT（现场证据；标明来源文件/命令/ID）
- 一次盘点任务的 spec 只写了 grep 目标，subagent 没读任何记忆，重复了上周已完成的排查。

## 决策／结论
- spec 模板加三项：① MEMORY.md 与相关 pack 路径 ② 用 `mem find` 取到的真实 note 名 ③ 「记忆与现场冲突以现场为准并回报」。

## 坑（下次怎么避开）
- note 名不要凭印象写，`mem find` 取、`mem show` 验。

## 相关
- [[2026-01-20-user-prefers-results]]
