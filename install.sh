#!/usr/bin/env bash
# install.sh — Hippocampus：安装 mem CLI 并初始化记忆根目录。不覆盖任何已有文件。
#
#   ./install.sh                         # CLI → ~/.local/bin/mem，初始化 ${MEM_HOME:-~/.claude/memory}
#   ./install.sh --examples              # 同上，并放入 examples/notes/ 里的虚构 note
#   ./install.sh --skill-dir DIR         # 另把本仓库作为 skill 拷到 DIR（如 ~/.claude/skills/hippocampus）
#   ./install.sh --agents-file FILE      # 把 prompts/agents-snippet.md 的规则段追加进 FILE（AGENTS.md / CLAUDE.md），已有则跳过
#   ./install.sh --hooks                 # 安装 Claude Code hooks 到 ~/.claude/hooks/mem，并合并进 ~/.claude/settings.json（先备份）
#   PREFIX=/usr/local ./install.sh       # 改安装前缀（bin 在 $PREFIX/bin）
#   MEM_HOME=/path ./install.sh          # 改记忆根目录
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${PREFIX:-$HOME/.local}"
MEM_HOME="${MEM_HOME:-$HOME/.claude/memory}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
WITH_EXAMPLES=0
WITH_HOOKS=0
SKILL_DIR=""
AGENTS_FILES=()
MARK_BEGIN="<!-- hippocampus:begin -->"
MARK_END="<!-- hippocampus:end -->"

while [ $# -gt 0 ]; do
  case "$1" in
    --examples) WITH_EXAMPLES=1 ;;
    --hooks) WITH_HOOKS=1 ;;
    --skill-dir) SKILL_DIR="${2:?--skill-dir 需要路径}"; shift ;;
    --agents-file) AGENTS_FILES+=("${2:?--agents-file 需要路径}"); shift ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "未知参数：$1" >&2; exit 2 ;;
  esac
  shift
done

command -v python3 >/dev/null || { echo "需要 python3 (>=3.8)" >&2; exit 1; }
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)' \
  || { echo "python3 版本过低，需要 >=3.8" >&2; exit 1; }

# 1) CLI
mkdir -p "$PREFIX/bin"
install -m 0755 "$HERE/scripts/mem" "$PREFIX/bin/mem"
echo "installed  $PREFIX/bin/mem"

# 2) 记忆根目录骨架（已存在的文件一律跳过）
mkdir -p "$MEM_HOME/notes" "$MEM_HOME/packs" "$MEM_HOME/.memorypack"
copy_if_absent() {  # src dst
  if [ -e "$2" ]; then echo "keep       $2"; else cp "$1" "$2"; echo "created    $2"; fi
}
copy_if_absent "$HERE/templates/packs.json" "$MEM_HOME/.memorypack/packs.json"
copy_if_absent "$HERE/templates/MEMORY.md"  "$MEM_HOME/MEMORY.md"
copy_if_absent "$HERE/templates/catalog.tsv" "$MEM_HOME/catalog.tsv"

if [ "$WITH_EXAMPLES" = 1 ]; then
  for f in "$HERE"/examples/notes/*.md; do
    copy_if_absent "$f" "$MEM_HOME/notes/$(basename "$f")"
  done
fi

# 3) 可选：作为 skill 安装
if [ -n "$SKILL_DIR" ]; then
  mkdir -p "$SKILL_DIR"
  for item in SKILL.md README.md LICENSE docs prompts templates scripts; do
    cp -R "$HERE/$item" "$SKILL_DIR/"
  done
  echo "skill      $SKILL_DIR"
fi

# 4) 可选：规则段追加进 AGENTS.md / CLAUDE.md（只追加，不改动已有内容；有标记则跳过）
snippet() {
  # 取 agents-snippet.md 中第一对 --- 之间的内容；非默认 MEM_HOME 时替换路径
  awk 'f==1 && /^---$/ {exit} f==1 {print} /^---$/ && f==0 {f=1}' "$HERE/prompts/agents-snippet.md" \
    | sed "s#~/.claude/memory/#${MEM_HOME_DISPLAY}/#g"
}
case "$MEM_HOME" in
  "$HOME"/*) MEM_HOME_DISPLAY="~/${MEM_HOME#"$HOME"/}" ;;
  *) MEM_HOME_DISPLAY="$MEM_HOME" ;;
esac
for af in "${AGENTS_FILES[@]+"${AGENTS_FILES[@]}"}"; do
  if [ -f "$af" ] && grep -qF "$MARK_BEGIN" "$af"; then
    echo "keep       $af（已含 Hippocampus 规则段）"
    continue
  fi
  mkdir -p "$(dirname "$af")"
  if [ -s "$af" ]; then cp "$af" "$af.bak.$(date +%Y%m%d%H%M%S)"; fi
  {
    [ -s "$af" ] && printf '\n'
    echo "$MARK_BEGIN"
    snippet
    echo "$MARK_END"
  } >> "$af"
  echo "appended   $af"
done

# 5) 可选：Claude Code hooks
if [ "$WITH_HOOKS" = 1 ]; then
  HOOK_DIR="$CLAUDE_DIR/hooks/mem"
  mkdir -p "$HOOK_DIR"
  for f in "$HERE"/prompts/hooks/*.sh; do
    install -m 0755 "$f" "$HOOK_DIR/$(basename "$f")"
  done
  echo "hooks      $HOOK_DIR"
  SETTINGS="$CLAUDE_DIR/settings.json"
  python3 - "$SETTINGS" "$HOOK_DIR" <<'PY'
import json, os, sys
path, hook_dir = sys.argv[1], sys.argv[2]
cfg = {}
if os.path.isfile(path):
    with open(path, encoding="utf-8") as fh:
        cfg = json.load(fh)
hooks = cfg.setdefault("hooks", {})
want = {
    "SessionStart": ("startup|resume|clear|compact", "session-start-memory.sh", None),
    "Stop": (None, "stop-review-reminder.sh", None),
    "SessionEnd": (None, "session-end-build.sh", 15),
}
added = []
for event, (matcher, script, timeout) in want.items():
    cmd = os.path.join(hook_dir, script)
    groups = hooks.setdefault(event, [])
    if any(h.get("command") == cmd for g in groups for h in g.get("hooks", [])):
        continue
    handler = {"type": "command", "command": cmd}
    if timeout:
        handler["timeout"] = timeout
    group = {"hooks": [handler]}
    if matcher:
        group["matcher"] = matcher
    groups.append(group)
    added.append(event)
if not added:
    print("settings   %s（hooks 已登记，未改动）" % path)
    sys.exit(0)
if os.path.isfile(path):
    import shutil, time
    shutil.copy2(path, path + time.strftime(".bak.%Y%m%d%H%M%S"))
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as fh:
    json.dump(cfg, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
print("settings   %s（新增：%s；原文件已备份为 .bak.<时间戳>）" % (path, ", ".join(added)))
PY
fi

# 6) 生成 Tier-0/1/2
"$PREFIX/bin/mem" --root "$MEM_HOME" build >/dev/null
echo "built      $MEM_HOME (mem build)"

case ":$PATH:" in
  *":$PREFIX/bin:"*) ;;
  *) echo "注意：$PREFIX/bin 不在 PATH 中，请加入 shell 配置：export PATH=\"$PREFIX/bin:\$PATH\"" ;;
esac
if [ "$MEM_HOME" != "$HOME/.claude/memory" ]; then
  echo "注意：非默认根目录，请在 shell 配置中 export MEM_HOME=\"$MEM_HOME\""
fi
