# Skiller SKILL.md validate (Windows PowerShell)
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$SkillDir
)

$SKILL_MD = Join-Path $SkillDir "SKILL.md"
$PASS = 0
$FAIL = 0

function Pass($msg) { Write-Host "  [PASS] $msg" -ForegroundColor Green; $script:PASS++ }
function Fail($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red; $script:FAIL++ }

Write-Host "=== Skiller Validate ===" -ForegroundColor Cyan
Write-Host "Checking: $SkillDir"
Write-Host ""

if (-not (Test-Path $SKILL_MD)) {
    Fail "SKILL.md not found"
    exit 1
}
Pass "SKILL.md found"

$content = Get-Content $SKILL_MD -Raw -Encoding UTF8
$lines = Get-Content $SKILL_MD -Encoding UTF8

# Frontmatter: starts with ---
if ($lines[0] -eq "---") { Pass "frontmatter opening ---" }
else { Fail "missing frontmatter opening ---" }

# name field
if ($content -match "(?m)^name:") { Pass "frontmatter has name" }
else { Fail "frontmatter missing name" }

# description field + length check (recommend <= 200 chars)
if ($content -match "(?m)^description:") {
    $descMatch = [regex]::Match($content, '(?m)^description:\s*"(.+?)"')
    if ($descMatch.Success) {
        $descText = $descMatch.Groups[1].Value
        $descLen = $descText.Length
        if ($descLen -le 250) { Pass "description length OK ($descLen chars, <= 250)" }
        else { Fail "description too long ($descLen chars, recommend <= 200)" }
    } else {
        $descLine = ($content -split "`n" | Where-Object { $_ -match "^description:" } | Select-Object -First 1)
        if ($descLine.Length -le 250) { Pass "description length OK" }
        else { Fail "description too long (recommend <= 200)" }
    }
} else { Fail "frontmatter missing description" }

# Required sections
$required = @("触发条件", "工作流程", "输出要求", "停止条件")
foreach ($sec in $required) {
    if ($content -match [regex]::Escape($sec)) { Pass "section found: $sec" }
    else { Fail "missing section: $sec" }
}

# "不适用" section (anti-examples)
if ($content -match "不适用") { Pass "anti-example section found" }
else { Fail "missing anti-example section" }

# Hardcoded model names check
$models = @("GPT", "Claude", "Gemini", "Llama")
$found = @()
foreach ($m in $models) {
    if ($content -match $m) { $found += $m }
}
if ($found.Count -eq 0) { Pass "no hardcoded model names" }
else { Fail "found hardcoded model names: $($found -join ', ')" }

# eval.json
$evalPath = Join-Path $SkillDir "evals\eval.json"
if (Test-Path $evalPath) {
    Pass "evals/eval.json found"
    try { $null = Get-Content $evalPath -Raw -Encoding UTF8 | ConvertFrom-Json; Pass "eval.json valid JSON" }
    catch { Fail "eval.json invalid JSON" }
} else { Fail "missing evals/eval.json" }

# Line count check (recommend <= 500)
$lineCount = $lines.Count
if ($lineCount -le 500) { Pass "line count OK ($lineCount lines, <= 500)" }
else { Fail "too long ($lineCount lines, recommend <= 500)" }

Write-Host ""
Write-Host "=== Result ===" -ForegroundColor Cyan
Write-Host "Pass: $PASS  Fail: $FAIL"
if ($FAIL -gt 0) { Write-Host "Some checks failed. Fix before using." -ForegroundColor Yellow; exit 1 }
else { Write-Host "All checks passed." -ForegroundColor Green }
