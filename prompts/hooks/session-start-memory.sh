#!/usr/bin/env bash
# SessionStart hook：把 Tier-0 路由表注入会话上下文。
# Claude Code 会把 SessionStart hook 的纯文本 stdout 加进上下文（单次上限约 10000 字符，
# 超出会被换成文件路径 + 预览；默认 router_budget_bytes=12000 字节，中文为主时一般在上限内）。
MEM_HOME="${MEM_HOME:-$HOME/.claude/memory}"
[ -f "$MEM_HOME/MEMORY.md" ] || exit 0
echo "以下是长期记忆路由表（$MEM_HOME/MEMORY.md）。需要细节时用 mem pack / mem find / mem show。"
echo
cat "$MEM_HOME/MEMORY.md"
