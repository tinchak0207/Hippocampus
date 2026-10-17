---
name: 2026-02-02-cli-flag-renamed
description: 示例 CLI 在 2.0 把 --out 改名为 --output，旧参数静默忽略；脚本里统一用 --output
metadata:
  type: reference
  pack: tooling
---

# 示例 CLI 2.0：--out 改名 --output

## FACT（现场证据；标明来源文件/命令/ID）
- `exampletool build --out dist` 在 2.0.1 上不报错，但产物仍写到默认目录 `build/`。

## 决策／结论
- 仓库内所有脚本改用 `--output`。

## 坑（下次怎么避开）
- 升级大版本后先看 CHANGELOG 的 "Renamed" 段。

## 相关
- [[]]
