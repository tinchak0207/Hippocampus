#!/usr/bin/env bash
# Stop hook：每个会话只提醒一次「会话末复盘」。
# exit 2 + stderr 会让 Claude 继续一轮并看到提示；stop_hook_active=true 时直接放行，避免循环。
# 依赖 python3 解析 stdin JSON（不需要 jq）。
input="$(cat)"
read -r active sid < <(printf '%s' "$input" | python3 -c '
import json, sys
d = json.load(sys.stdin)
print(str(d.get("stop_hook_active", False)).lower(), d.get("session_id", "unknown"))
')
[ "$active" = "true" ] && exit 0
mark="${TMPDIR:-/tmp}/mem-review-${sid//[^A-Za-z0-9_-]/_}"
[ -e "$mark" ] && exit 0
: > "$mark"
cat >&2 <<'MSG'
结束前做一次记忆复盘（见 prompts/proactive-build.md 第 1 节）：
本次会话是否有可复用结果、查明的原因、用户纠正、决策、过期记忆？
有就 `mem add <slug> --type ...` 填好 description 后 `mem build`，并用一行列出改动的 note 名；
没有就直接结束，不要硬写。
MSG
exit 2
