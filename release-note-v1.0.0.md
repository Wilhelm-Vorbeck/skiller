**首个正式发布版本。** 一个跨平台的 Agent Skill 设计教练，覆盖 Skill 创建、评估、维护和退役全生命周期。

### 包含内容

- **SKILL.md** — 完整的设计方法论和 8 步工作流
- **6 条核心设计原则** — 写动作不写原则、description 路由、渐进式加载、上下文税、脚本化、可迁移性
- **迭代方法** — SkillOpt 四步循环 + Gotchas 飞轮
- **多 Skill 治理** — 路由冲突处理 + 退役条件
- **脚本** — `init.sh` / `init.ps1`（初始化 Skill 目录骨架）、`validate.sh` / `validate.ps1`（校验 SKILL.md）
- **Evals** — 7 条评测样本（标准 / 边界 / 反例）
- **平台支持** — TRAE / Codex / Qoder / 通用

### 安装方式

**方式 1：通过 Release 压缩包安装**

1. 下载 `Skiller.v1.0.0.rar`
2. 解压到你的 Agent Skill 目录：

**Windows（PowerShell）：**
```powershell
$target = "$env:USERPROFILE\.trae\skills\skiller"
New-Item -ItemType Directory -Force -Path $target | Out-Null
& 'C:\Program Files\7-Zip\7z.exe' x "$env:USERPROFILE\Downloads\Skiller.v1.0.0.rar" -o"$target" -y
```

**macOS / Linux：**
```bash
mkdir -p ~/.agent/skills/skiller
unrar x ~/Downloads/Skiller.v1.0.0.rar ~/.agent/skills/skiller/
```

目标路径可按你的平台替换：
- **TRAE** → `.trae/skills/skiller/`
- **Codex** → `~/.codex/skills/skiller/`
- **Qoder** → `~/.qoderwork/skills/skiller/`
- **通用** → `~/.agent/skills/skiller/`

**方式 2：Git 克隆**

```bash
git clone https://github.com/Wilhelm-Vorbeck/skiller.git
cp -r skiller ~/.agent/skills/skiller
```

### 使用

对话中说"帮我创建个 Skill"、"这个 Skill 是不是有问题"即可触发。
