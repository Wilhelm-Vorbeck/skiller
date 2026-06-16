# Skiller — Agent Skill 设计教练

> 不只是一键生成 Skill，而是帮你判断值不值得做、怎么做对、怎么持续维护。

## 这是什么

**Skiller** 是一个给 AI Agent 使用的 Skill，它本身不执行具体业务任务，而是帮助**你**把反复出现的任务沉淀成 Agent 可以稳定执行的工作流——即帮你设计和创建新的 Skill。

它涵盖全流程：场景澄清 → 值得做判断 → description 编写 → SKILL.md 骨架搭建 → 工作流定义 → 验收检查 → eval 设计 → 迭代优化。也支持诊断已有 Skill 的路由冲突、误触发问题和退役判断。

## 与各平台内置 skill-creator 的区别

| 维度 | 各平台内置版 | Skiller |
|---|---|---|
| 定位 | Skill 工厂（一键生成） | Skill 设计教练（先判断再动手） |
| 核心能力 | 生成文件 | 评估 + 设计 + 生成 + 维护 + 退役 |
| 中文支持 | 英文为主 | 中文原生 |
| 平台适配 | 绑定各自的生态 | 跨平台自适应（TRAE/Codex/Qoder） |
| 迭代方法论 | 基本不涉及 | 完整 SkillOpt 四步循环 + Gotchas 飞轮 |
| 退役判断 | 不涉及 | 5 条退役条件 |

## 目录结构

```
skiller/
├── SKILL.md              # 核心说明书（Agent 读取）
├── README.md             # 本文件（人类阅读）
├── LICENSE               # MIT
├── scripts/
│   ├── init.sh           # Unix 初始化脚本
│   ├── init.ps1          # Windows 初始化脚本
│   ├── validate.sh       # Unix 校验脚本
│   └── validate.ps1      # Windows 校验脚本
└── evals/
    └── eval.json         # 评测集（标准/边界/反例）
```

## 安装

### 方式一：直接复制目录

根据你使用的 Agent 平台，复制到对应目录：

- **TRAE**：复制到 `.trae/skills/skiller/`
- **Codex**：复制到 `$CODEX_HOME/skills/skiller/`（通常为 `~/.codex/skills/skiller/`）
- **Qoder**：复制到 `~/.qoderwork/skills/skiller/`
- **通用**：复制到 `~/.agent/skills/skiller/`

### 方式二：使用初始化脚本

```bash
# Unix/macOS
chmod +x scripts/init.sh
./scripts/init.sh skiller ~/.agent/skills

# Windows
.\scripts\init.ps1 skiller "$env:USERPROFILE\.agent\skills"
```

然后复制 SKILL.md 到生成的目录。

### 方式三：Git 克隆

```bash
git clone https://github.com/<your-username>/skiller.git
cp -r skiller ~/.agent/skills/skiller
```

## 使用方式

安装后，在对话中说类似以下任一表达即自动触发：

- "帮我创建一个 Skill"
- "这个流程能不能沉淀成 Skill"
- "帮我看看我这个 Skill 有什么问题"
- "这两个 Skill 总是冲突怎么办"
- "这个 Skill 是不是该退役了"

## 平台兼容性

已验证可在以下平台使用：

| 平台 | 状态 | 备注 |
|---|---|---|
| TRAE | ✅ 已验证 | 默认路径 `.trae/skills/` |
| Codex | ✅ 兼容 | 路径 `$CODEX_HOME/skills/` |
| Qoder | ✅ 兼容 | 路径 `~/.qoderwork/skills/` |
| 其他支持 SKILL.md 的 Agent | ✅ 理论兼容 | 按平台调整目录路径 |

## 方法论参考

- [SkillOpt (Microsoft, 2025)](https://arxiv.org/abs/2605.23904) — Skill 迭代优化框架
- [SKILL0 (ZJU/Meituan, 2025)](https://arxiv.org/abs/2604.02268) — Skill 内化与退役
- [Skill1 (USTC/Meituan, 2025)](https://arxiv.org/abs/2605.06130) — 技能库协同进化

## License

MIT
