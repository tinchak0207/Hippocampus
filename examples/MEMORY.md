# 长期记忆（Tier-0 路由表）

> 单一真源 `notes/`（6 篇 / 3 KB）。本文件由 `mem build` 生成，**禁止手改**。
> 生成时间 2026-10-17 20:56｜预算 12000 bytes。

## 读取协定
1. 先读本文件（Tier-0，全部）。
2. 要细节 → `mem find <关键字>`（grep `catalog.tsv`，一行一篇，不回传全文）或读 `packs/<id>.md`。
3. 原始 note 在 `notes/`，**一次只读 catalog 指到的那几篇**；禁止整目录读取。

## 写入协定
- 新记忆：`mem add <slug> --type project|feedback|reference [--pack <id>]` → 在 `notes/` 生成带 front-matter 的文件；填好 `description`。
- 写完跑 `mem build`；**永不手改 `MEMORY.md` / `packs/*` / `catalog.tsv`**（改了下次 build 就被覆盖）。

## 领域包（Tier-1）

| pack | 条目 | 最近 | 什么时候读 |
|---|---|---|---|
| [`decisions`](packs/decisions.md) · 决策／偏好／工作纪律 | 1 | 2026-01-20 | 决定做不做、定口径、被用户纠正过的行为、取舍时 |
| [`infra`](packs/infra.md) · 基础设施／部署 | 2 | 2026-01-15 | 碰服务器、部署、域名、CI、容器、日志时 |
| [`tooling`](packs/tooling.md) · Agent／工具／脚本 | 2 | 2026-02-10 | 碰 agent 行为、工具、skill、MCP、脚本时 |
| [`misc`](packs/misc.md) · 未分类 | 1 | 2026-02-14 | 上面的 pack 都查不到时；或 `mem find <关键字>` |

## 热档（近期）

- 2026-02-14 [自动分类示例：未命中任何关键词](notes/2026-02-14-random-observation.md) — 没有钉 pack 的 note 会按关键词自动分类；这篇不含任何 pack 关键词，所以落到 misc
- 2026-02-10 [subagent spec 必须带「必读记忆」节](notes/2026-02-10-subagent-spec-needs-memory.md) — 派 subagent 时 spec 必须带「必读记忆」节：MEMORY.md + 相关 pack + 2-5 个 note 名；否则 subagent 会从零考古
- 2026-02-02 [示例 CLI 2.0：--out 改名 --output](notes/2026-02-02-cli-flag-renamed.md) — 示例 CLI 在 2.0 把 --out 改名为 --output，旧参数静默忽略；脚本里统一用 --output
- 2026-01-20 [交付结果，不交建议清单（用户纠正 01-20）](notes/2026-01-20-user-prefers-results.md) — 用户纠正：要的是改好的代码和跑通的命令，不是分析报告；研究类任务做完问一句「要不要落地」
- 2026-01-15 [部署脚本只建 release，不重启服务](notes/2026-01-15-release-vs-restart.md) — 部署分两步：release.sh 只建 release 目录并切软链接，restart.sh 才让新进程生效；判断是否上线看进程工作目录，不看软链接
- 2026-01-08 [健康检查端口：/healthz 只在 8081](notes/2026-01-08-healthz-port.md) — 示例服务的 /healthz 只在内部端口 8081 暴露；探活脚本必须打内网地址，打公网 443 永远 404

<!-- 末行：6 notes / 4 packs -->
