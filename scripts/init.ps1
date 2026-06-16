# Skiller — Skill 目录初始化脚本 (Windows PowerShell)
# 用法: .\init.ps1 <skill-name> [target-dir]
# 示例: .\init.ps1 my-skill "$env:USERPROFILE\.agent\skills"

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$SkillName,

    [Parameter(Position=1)]
    [string]$TargetDir = ""
)

if (-not $TargetDir) {
    $TargetDir = Join-Path $env:USERPROFILE ".agent\skills\$SkillName"
}

Write-Host "=== Skiller Init ===" -ForegroundColor Cyan
Write-Host "Skill 名称: $SkillName"
Write-Host "目标路径: $TargetDir"
Write-Host ""

# 检查是否已存在
if (Test-Path $TargetDir) {
    Write-Host "⚠ 目录已存在: $TargetDir" -ForegroundColor Yellow
    Write-Host "如果要覆盖，请先手动删除或重命名。"
    exit 1
}

# 创建目录结构
New-Item -ItemType Directory -Force -Path "$TargetDir\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\references" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\examples" | Out-Null
New-Item -ItemType Directory -Force -Path "$TargetDir\evals" | Out-Null

# 生成 SKILL.md 骨架
$SKILL_MD = @"
---
name: "$SkillName"
description: "当用户...时使用。[场景 + 输入 + 输出，≤ 200 字符]"
---

# {Skill 标题}

## 触发条件
- [用户说什么、给什么输入时触发]

## 不适用
- [看起来像但不该触发的场景]

## 工作流程
1. [步骤一（具体动作 + 产出）]
2. [步骤二]
3. ...

## 输出要求
- [格式规范]
- [质量标准]

## 停止条件
- 缺必要输入时：[行为]
- 权限失败时：[行为]
- 高风险动作：[行为]
"@
Set-Content -Path "$TargetDir\SKILL.md" -Value $SKILL_MD -Encoding UTF8

# 生成 eval.json 骨架
$EVAL_JSON = @"
{
  "skill_name": "$SkillName",
  "evals": [
    {
      "id": 1,
      "type": "standard",
      "prompt": "<真实任务描述>",
      "expected_output": "<期望交付物>",
      "assertions": [
        { "id": "a1", "text": "<可检查的断言>" }
      ]
    },
    {
      "id": 2,
      "type": "boundary",
      "prompt": "<边界输入>",
      "expected_output": "<期望行为>",
      "assertions": [
        { "id": "b1", "text": "<边界情况的断言>" }
      ]
    },
    {
      "id": 3,
      "type": "anti",
      "prompt": "<不应触发的输入>",
      "expected_output": "不加载此 Skill",
      "assertions": [
        { "id": "c1", "text": "没有执行此 Skill 的流程" }
      ]
    }
  ]
}
"@
Set-Content -Path "$TargetDir\evals\eval.json" -Value $EVAL_JSON -Encoding UTF8

# 生成 .gitkeep
New-Item -ItemType File -Force -Path "$TargetDir\references\.gitkeep" | Out-Null
New-Item -ItemType File -Force -Path "$TargetDir\examples\.gitkeep" | Out-Null

Write-Host ""
Write-Host "✓ Skill 目录已初始化: $TargetDir" -ForegroundColor Green
Write-Host ""
Write-Host "目录结构:"
Get-ChildItem -Recurse -Name $TargetDir | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "下一步: 编辑 $TargetDir\SKILL.md 填充具体内容"
