# 基础设施／部署（infra）

> 条目 2｜最近 2026-01-15｜生成 2026-01-15 21:00（`mem build` 生成，勿手改）
> 什么时候读：碰服务器、部署、域名、CI、容器、日志时
> 定位单一条目用 `mem find <关键字>`（grep catalog.tsv）；本文件可扫读，别整篇背。

### 2026-01-15 · 部署脚本只建 release，不重启服务
- deploy 分两步：release.sh 建目录切软链接，restart.sh 才让新进程生效；验证看进程工作目录而不是软链接
  - → `notes/2026-01-15-release-vs-restart.md`

### 2026-01-08 · 健康检查端口
- /healthz 走内部端口 8081，对外 443 不暴露；探活脚本要用内网地址
  - → `notes/2026-01-08-healthz-port.md`
