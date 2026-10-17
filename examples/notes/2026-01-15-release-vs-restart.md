---
name: 2026-01-15-release-vs-restart
description: 部署分两步：release.sh 只建 release 目录并切软链接，restart.sh 才让新进程生效；判断是否上线看进程工作目录，不看软链接
metadata:
  type: project
  pack: infra
---

# 部署脚本只建 release，不重启服务

## FACT（现场证据；标明来源文件/命令/ID）
- 跑完 `release.sh` 后 `current -> releases/42`，但 `readlink /proc/<pid>/cwd` 仍是 `releases/41`。

## 决策／结论
- 上线 = `release.sh && restart.sh`；验收看进程 cwd。

## 坑（下次怎么避开）
- 软链接会骗人。

## 相关
- [[2026-01-08-healthz-port]]
