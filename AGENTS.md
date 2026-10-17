# AGENTS.md

给在本仓库里工作的 agent 看的开发说明。用户文档在 `README.md`，安装给 agent 执行的步骤在 `docs/AGENT_INSTALL.md`。

## 这是什么

Hippocampus 是一个 Agent Skill 加一个 CLI：`mem`。它把 `notes/*.md` 编译成三层索引（`catalog.tsv` → `packs/<id>.md` → `MEMORY.md`），让 agent 用固定、很小的上下文查到过去的教训。

## 结构

| 路径 | 内容 | 改动注意 |
|---|---|---|
| `scripts/mem` | CLI，单文件 Python，只用标准库 | 主要代码都在这里 |
| `install.sh` | 安装 CLI、初始化 `MEM_HOME`、追加规则段、装 hooks | 必须幂等，不覆盖已有文件 |
| `SKILL.md` | Skill 入口，frontmatter `name: hippocampus` | `name` 不改；`description` 写「何时调用」 |
| `prompts/` | 维护与主动建设提示词、规则段、hooks 示例 | `agents-snippet.md` 第一对 `---` 之间的内容会被 `install.sh` 原样抽出 |
| `templates/` | 空库模板、`packs.json`、note/pack 示例 | 改 note 模板要同步 `scripts/mem` 里的 `ADD_TMPL` |
| `examples/` | 虚构演示库，已 build | 改了 `scripts/mem` 的输出格式后重新 build |
| `docs/AGENT_INSTALL.md` | 给 agent 执行的安装步骤 | README 里的自装提示词指向它的 raw URL |
| `tests/smoke.sh` | 端到端冒烟测试 | 新增子命令或安装选项时补一段 |

## 本地测试

```bash
tests/smoke.sh                                    # 在临时 HOME 里跑完整流程，最后打印 ALL OK
python3 scripts/mem --root examples build         # 重建演示库
python3 scripts/mem --root examples doctor        # 应为 VERDICT: OK
bash -n install.sh prompts/hooks/*.sh             # shell 语法检查
```

`tests/smoke.sh` 会重设 `HOME`、`MEM_HOME`、`PREFIX`，不会碰你自己的 `~/.claude` 或 `~/.local`。不要在测试里用真实的记忆库。

提交前跑一次去敏扫描，结果必须为空：

```bash
rg -n -i --hidden -g '!.git' -e '/ho[m]e/[a-z]' -e '[@]gmail' -e 'sk[-][A-Za-z0-9]' -e '\b\d{1,3}(\.\d{1,3}){3}\b' .
```

## 编码约定

- Python ≥ 3.8，只用标准库。不引入依赖。
- `scripts/mem` 保持单文件，可以直接 `cp` 到任何 `PATH` 目录运行。
- 生成物（`MEMORY.md`、`packs/*`、`catalog.tsv`）只由 `build()` 写；其他命令只读它们。`find` 不返回 note 原文。
- 不删除用户数据。需要清理的东西移到 `archive/`。
- 新配置项一律放进 `DEFAULT_CFG` 并给默认值，旧的 `packs.json` 不改也要能用。
- 用户可见的输出与文档以简体中文为主；README 英文段在后。
- shell 脚本：`set -euo pipefail`，路径加引号，能重复执行。
- 示例数据必须虚构。不要放任何真实记忆、密钥、主机名、内部路径、邮箱。
- 不用 emoji。

## 发版

- 版本号在 `scripts/mem` 的 `__version__`，遵循 SemVer：
  - patch：修 bug、改文档；
  - minor：新子命令、新配置项、新安装选项（向后兼容）；
  - major：改变 note front-matter、`catalog.tsv` 列、目录结构，或让旧的 `packs.json` 不能用。
- 发版步骤：改 `__version__` → `tests/smoke.sh` 通过 → 重建 `examples/` → 去敏扫描为空 → 一个 commit `release: vX.Y.Z` → 打 tag `vX.Y.Z` → push。
- 不 force push 到 `main`。
