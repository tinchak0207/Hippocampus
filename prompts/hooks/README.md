# hooks 示例（Claude Code）

三个可选 hook，互相独立，按需取用。它们不替 agent 写记忆内容，只负责「注入」「提醒」「重建」。

| 文件 | 事件 | 行为 |
|---|---|---|
| `session-start-memory.sh` | `SessionStart` | 把 `MEMORY.md` 打印到 stdout，Claude Code 将其加入会话上下文 |
| `stop-review-reminder.sh` | `Stop` | 每个会话第一次结束时 exit 2，提示做会话末复盘；同一会话不再重复 |
| `session-end-build.sh` | `SessionEnd` | `notes/` 有比 `catalog.tsv` 新的文件时跑 `mem build` |

安装：

```bash
mkdir -p ~/.claude/hooks/mem
cp prompts/hooks/*.sh ~/.claude/hooks/mem/
chmod +x ~/.claude/hooks/mem/*.sh
# 把 settings.example.json 的 "hooks" 段合并进 ~/.claude/settings.json（不要整文件覆盖）
```

说明：

- 若设置了非默认 `MEM_HOME`，确保 Claude Code 的进程环境里也有它（或在脚本里写死）。
- `stop-review-reminder.sh` 会让每个会话多一轮对话，不需要时不要启用。
- 其他 agent 运行时（Codex、OpenCode 等）没有相同的 hook 接口；可以把 `prompts/agents-snippet.md` 粘进规则文件，作用相同但依赖 agent 自觉。
