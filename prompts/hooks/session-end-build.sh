#!/usr/bin/env bash
# SessionEnd hook：notes/ 有比 catalog.tsv 新的文件时自动 mem build，防止忘记重建。
# 只做重建，不新建、不删除任何 note。
MEM_HOME="${MEM_HOME:-$HOME/.claude/memory}"
command -v mem >/dev/null || exit 0
[ -d "$MEM_HOME/notes" ] || exit 0
if [ ! -f "$MEM_HOME/catalog.tsv" ] || [ -n "$(find "$MEM_HOME/notes" -name '*.md' -newer "$MEM_HOME/catalog.tsv" -print -quit)" ]; then
  mem --root "$MEM_HOME" build >/dev/null 2>&1 || true
fi
exit 0
