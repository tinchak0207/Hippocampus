---
name: 2026-01-08-healthz-port
description: 示例服务的 /healthz 只在内部端口 8081 暴露；探活脚本必须打内网地址，打公网 443 永远 404
metadata:
  type: reference
  pack: infra
---

# 健康检查端口：/healthz 只在 8081

## FACT（现场证据；标明来源文件/命令/ID）
- `curl -s localhost:8081/healthz` → `ok`；`curl -s https://example.com/healthz` → 404（2026-01-08）
- 反向代理配置只转发 `/api/*` 和静态文件。

## 决策／结论
- 不对外暴露 healthz；外部监控改走 `/api/ping`。

## 坑（下次怎么避开）
- 看到外部 404 不要以为服务挂了，先打 8081。

## 相关
- [[2026-01-15-release-vs-restart]]
