#!/usr/bin/env bash
# Skiller — SKILL.md 校验脚本 (Unix/macOS)
# 用法: ./validate.sh <skill-dir>
# 检查项: frontmatter、必要章节、路径引用、硬编码模型名

set -euo pipefail

SKILL_DIR="${1:?用法: ./validate.sh <skill-dir>}"
SKILL_MD="$SKILL_DIR/SKILL.md"
PASS=0
FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo "=== Skiller Validate ==="
echo "检查: $SKILL_DIR"
echo ""

# 1. SKILL.md 存在
if [ -f "$SKILL_MD" ]; then
    pass "SKILL.md 存在"
else
    fail "SKILL.md 不存在"
    echo ""
    echo "结果: 严重错误，无法继续"
    exit 1
fi

# 2. Frontmatter 检查
FIRST_LINE=$(head -1 "$SKILL_MD")
if [ "$FIRST_LINE" = "---" ]; then
    pass "frontmatter 开头正确"
else
    fail "缺少 frontmatter 开头 ---"
fi

# 检查 name 字段
if grep -q "^name:" "$SKILL_MD"; then
    pass "frontmatter 包含 name"
else
    fail "frontmatter 缺少 name"
fi

# 检查 description 字段
if grep -q "^description:" "$SKILL_MD"; then
    DESC=$(grep "^description:" "$SKILL_MD" | head -1)
    DESC_LEN=${#DESC}
    if [ "$DESC_LEN" -le 250 ]; then
        pass "description 长度合理 (≤ 250 字符)"
    else
        fail "description 过长 ($DESC_LEN 字符，建议 ≤ 200)"
    fi
else
    fail "frontmatter 缺少 description"
fi

# 3. 必要章节检查
for section in "触发条件" "工作流程" "输出要求" "停止条件"; do
    if grep -q "$section" "$SKILL_MD"; then
        pass "包含章节: $section"
    else
        fail "缺少章节: $section"
    fi
done

# 4. 不适用检查
if grep -q "不适用" "$SKILL_MD"; then
    pass "包含「不适用」节"
else
    fail "缺少「不适用」节（应有反例）"
fi

# 5. 硬编码模型名检查
MODEL_NAMES="GPT Claude Gemini Llama"
FOUND_MODELS=""
for model in $MODEL_NAMES; do
    if grep -qi "$model" "$SKILL_MD"; then
        FOUND_MODELS="$FOUND_MODELS $model"
    fi
done
if [ -z "$FOUND_MODELS" ]; then
    pass "没有硬编码模型名称"
else
    fail "发现硬编码模型名称:$FOUND_MODELS"
fi

# 6. 绝对路径检查（排除 frontmatter）
ABSOLUTE_PATHS=$(grep -n '/' "$SKILL_MD" | grep -v '^[0-9]*:---' | grep -v 'http' | grep -v '//' | grep -c '^/' || true)
if [ "$ABSOLUTE_PATHS" -eq 0 ] 2>/dev/null; then
    pass "没有硬编码绝对路径"
else
    fail "发现 $ABSOLUTE_PATHS 处可能的绝对路径引用"
fi

# 7. eval.json 检查
if [ -f "$SKILL_DIR/evals/eval.json" ]; then
    pass "evals/eval.json 存在"
    if command -v python3 &>/dev/null; then
        if python3 -m json.tool "$SKILL_DIR/evals/eval.json" > /dev/null 2>&1; then
            pass "eval.json JSON 格式有效"
        else
            fail "eval.json JSON 格式无效"
        fi
    else
        echo "  - python3 未安装，跳过 JSON 格式校验"
    fi
else
    fail "缺少 evals/eval.json"
fi

# 8. 行数检查
LINE_COUNT=$(wc -l < "$SKILL_MD")
if [ "$LINE_COUNT" -le 500 ]; then
    pass "SKILL.md 行数合理 ($LINE_COUNT 行，≤ 500)"
else
    fail "SKILL.md 过长 ($LINE_COUNT 行，建议 ≤ 500)"
fi

echo ""
echo "=== 检查完成 ==="
echo "通过: $PASS  失败: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    echo "结果: ⚠ 有 $FAIL 项未通过，建议修复后再使用"
    exit 1
else
    echo "结果: ✓ 全部通过"
fi
