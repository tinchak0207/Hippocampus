# Hippocampus：给 agent 的安装步骤

本文件写给正在替用户安装 Hippocampus 的 coding agent（Claude Code、Codex、Cursor 等）。按顺序执行，每一步都检查输出。不要覆盖用户已有的文件；`install.sh` 本身不覆盖，追加规则段前会备份。

## 0. 先确认

- 需要 `git` 和 `python3`（≥ 3.8）。`python3 --version` 检查。
- 确认用户项目根目录（下称 `$PROJECT`），以及项目用的是 `AGENTS.md`、`CLAUDE.md` 还是两者都有。都没有时用 `AGENTS.md`。
- 记忆根目录默认 `~/.claude/memory`。如果它已存在且有内容，**不要删除或移动**，`install.sh` 会保留其中所有文件。用户要求放别处时，设 `MEM_HOME`。

## 1. 获取代码

```bash
SRC="${HIPPOCAMPUS_SRC:-$HOME/.local/share/hippocampus}"
if [ -d "$SRC/.git" ]; then
  git -C "$SRC" pull --ff-only
else
  git clone https://github.com/tinchak0207/Hippocampus.git "$SRC"
fi
```

## 2. 安装 CLI、初始化记忆库、合并规则段

```bash
cd "$SRC"
./install.sh --agents-file "$PROJECT/AGENTS.md"
# 项目用 CLAUDE.md：--agents-file "$PROJECT/CLAUDE.md"
# 两个都有：两个 --agents-file 都传
# 自定义位置：MEM_HOME=/path/to/memory ./install.sh ...
```

它做的事：

| 输出前缀 | 含义 |
|---|---|
| `installed` | `mem` 已复制到 `${PREFIX:-~/.local}/bin/mem` |
| `created` / `keep` | 记忆库骨架文件新建 / 已存在而保留 |
| `appended` | 规则段已追加到文件末尾，夹在 `<!-- hippocampus:begin -->` 与 `<!-- hippocampus:end -->` 之间；原文件有内容时先存了 `.bak.<时间戳>` |
| `keep ...（已含 Hippocampus 规则段）` | 文件里已有标记，未改动 |
| `built` | 已跑过 `mem build` |

重复执行是安全的。

## 3. 可选：Claude Code hooks

只在用户使用 Claude Code 且同意时执行：

```bash
./install.sh --hooks
```

- 把三个脚本装到 `~/.claude/hooks/mem/`。
- 合并进 `~/.claude/settings.json`：只追加 `SessionStart`、`Stop`、`SessionEnd` 三项，已有的 hooks 和其他设置不动；改之前存 `.bak.<时间戳>`。
- `Stop` 那一项会在每个会话第一次结束时多要求一轮复盘。用户不想要的话，从 settings.json 删掉那一项。
- 非默认 `MEM_HOME` 时，Claude Code 的进程环境里也要有 `MEM_HOME`。

## 4. PATH 与环境变量

`install.sh` 末尾若打印「不在 PATH 中」或「非默认根目录」，把对应的 `export` 行加入用户的 shell 配置（`~/.bashrc`、`~/.zshrc` 等），先告诉用户你改了哪个文件。当前会话里直接 `export` 一次以便后续验证。

## 5. 自检

```bash
mem --version
mem doctor
```

期望 `VERDICT: OK`。新库没有 note 时也是 OK。

再走一遍写读闭环，确认后删掉这篇测试 note（这是你刚建的测试文件，删除它不算删除用户记忆）：

```bash
f=$(mem add hippocampus-install-check --type reference --pack misc)
mem build >/dev/null
mem find install-check
rm "$f" && mem build >/dev/null
```

## 6. 回报给用户

- 代码位置（`$SRC`）、`mem` 路径、`MEM_HOME`。
- 改动过的文件及备份路径（AGENTS.md / CLAUDE.md / settings.json / shell 配置）。
- `mem doctor` 输出。
- 一句话用法：开始任务前 `mem find <关键字>` 查教训；犯错、查明原因、做决定之后 `mem add` + `mem build`。

## 卸载

```bash
rm ~/.local/bin/mem
rm -rf ~/.claude/hooks/mem        # 若装过 hooks，并从 settings.json 删掉对应三项
# 规则段：删除 AGENTS.md / CLAUDE.md 中 hippocampus:begin 到 hippocampus:end 之间的内容
# 记忆库 $MEM_HOME 是用户数据，除非用户明确要求，不要删除
```
