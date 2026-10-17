#!/usr/bin/env bash
# tests/smoke.sh — 在临时目录里跑完整流程：install → add → build → find → show → pack → ls → doctor → sweep → hooks。
# 不触碰真实的 ~/.claude、~/.local。任何一步失败即退出非零。
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
export HOME="$T/fakehome" MEM_HOME="$T/fakehome/.claude/memory" PREFIX="$T/fakehome/.local"
export PATH="$PREFIX/bin:$PATH" TMPDIR="$T"
mkdir -p "$HOME/project"
printf '# Project rules\n\nexisting line\n' > "$HOME/project/AGENTS.md"

q() { local pat="$1"; shift; local o; o="$("$@")" || true; grep -q -- "$pat" <<<"$o"; }
step() { printf '\n== %s\n' "$*"; }

step install
"$HERE/install.sh" --examples --hooks --agents-file "$HOME/project/AGENTS.md" --skill-dir "$HOME/.claude/skills/hippocampus"
out="$("$HERE/install.sh" --agents-file "$HOME/project/AGENTS.md" --hooks)"
grep -q '已含 Hippocampus 规则段' <<<"$out"
grep -q 'existing line' "$HOME/project/AGENTS.md"
[ "$(grep -c 'hippocampus:begin' "$HOME/project/AGENTS.md")" = 1 ]
python3 - "$HOME/.claude/settings.json" <<'PY'
import json, sys
h = json.load(open(sys.argv[1]))["hooks"]
assert all(len(h[e]) == 1 for e in ("SessionStart", "Stop", "SessionEnd")), h
PY

step add/build
f="$(mem add smoke-check --type reference --pack infra --title 'smoke check note')"
sed -i 's/^description: .*/description: smoke 测试专用 note，关键词 zebra-unique/' "$f"
mem add smoke-check >/dev/null && { echo "add 应拒绝重复"; exit 1; } || true
mem build >/dev/null

step find/show/pack/ls
q 'smoke-check' mem find zebra-unique
q '1 命中' mem find zebra-unique --pack infra --limit 1
q 'zebra-unique' mem show smoke-check
q 'zebra-unique' mem pack infra
q '^infra' mem ls
mem pack nope >/dev/null && exit 1 || true

step doctor/sweep
q 'VERDICT: OK' mem doctor
cp "$MEM_HOME/MEMORY.md" "$MEM_HOME/notes/MEMORY.md"
mem doctor >/dev/null && exit 1 || true
q 'swept 1' mem sweep
q 'VERDICT: OK' mem doctor

step hooks
q 'Tier-0' "$HOME/.claude/hooks/mem/session-start-memory.sh"
set +e
echo '{"session_id":"s1","stop_hook_active":false}' | "$HOME/.claude/hooks/mem/stop-review-reminder.sh" 2>/dev/null; r1=$?
echo '{"session_id":"s1","stop_hook_active":false}' | "$HOME/.claude/hooks/mem/stop-review-reminder.sh" 2>/dev/null; r2=$?
set -e
[ "$r1" = 2 ] && [ "$r2" = 0 ]
"$HOME/.claude/hooks/mem/session-end-build.sh"

step empty-store
E="$T/empty"
mem --root "$E" add first >/dev/null
q 'placeholder' mem --root "$E" doctor

printf '\nALL OK\n'
