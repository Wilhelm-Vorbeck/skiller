#!/usr/bin/env bash
# Skiller — Skill 目录初始化脚本 (Unix/macOS)
# 用法: ./init.sh <skill-name> [target-dir]
# 示例: ./init.sh my-skill ~/.agent/skills

set -euo pipefail

SKILL_NAME="${1:?用法: ./init.sh <skill-name> [target-dir]}"
TARGET_DIR="${2:-$HOME/.agent/skills/$SKILL_NAME}"

echo "=== Skiller Init ==="
echo "Skill 名称: $SKILL_NAME"
echo "目标路径: $TARGET_DIR"
echo ""

# 检查是否已存在
if [ -d "$TARGET_DIR" ]; then
    echo "⚠ 目录已存在: $TARGET_DIR"
    echo "如果要覆盖，请先手动删除或重命名。"
    exit 1
fi

# 创建目录结构
mkdir -p "$TARGET_DIR/scripts"
mkdir -p "$TARGET_DIR/references"
mkdir -p "$TARGET_DIR/examples"
mkdir -p "$TARGET_DIR/evals"

# 生成 SKILL.md 骨架
cat > "$TARGET_DIR/SKILL.md" << 'SKELETON'
---
name: "{SKILL_NAME}"
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
SKELETON

# 替换占位符
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/{SKILL_NAME}/$SKILL_NAME/g" "$TARGET_DIR/SKILL.md"
else
    sed -i "s/{SKILL_NAME}/$SKILL_NAME/g" "$TARGET_DIR/SKILL.md"
fi

# 生成 eval.json 骨架
cat > "$TARGET_DIR/evals/eval.json" << 'EVALJSON'
{
  "skill_name": "{SKILL_NAME}",
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
EVALJSON

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/{SKILL_NAME}/$SKILL_NAME/g" "$TARGET_DIR/evals/eval.json"
else
    sed -i "s/{SKILL_NAME}/$SKILL_NAME/g" "$TARGET_DIR/evals/eval.json"
fi

# 生成 .gitkeep
touch "$TARGET_DIR/references/.gitkeep"
touch "$TARGET_DIR/examples/.gitkeep"

echo ""
echo "✓ Skill 目录已初始化: $TARGET_DIR"
echo ""
echo "目录结构:"
find "$TARGET_DIR" -type f -o -type d | sort | sed "s|$TARGET_DIR/|  |"
echo ""
echo "下一步: 编辑 $TARGET_DIR/SKILL.md 填充具体内容"
