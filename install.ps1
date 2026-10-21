# Antigravity 规则与 MCP 本地安装脚本 (Windows PowerShell)
$ErrorActionPreference = "Stop"

$geminiDir = "$HOME\.gemini"
$targetFile = "$geminiDir\GEMINI.md"
$skillTargetDir = "$geminiDir\config\skills\codebase-memory"
$sourceFile = "$PSScriptRoot\GEMINI.md"
$skillSourceFile = "$PSScriptRoot\skills\codebase-memory\SKILL.md"

New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
New-Item -ItemType Directory -Force -Path $skillTargetDir | Out-Null

Copy-Item -Path $sourceFile -Destination $targetFile -Force
Write-Host "=============================================" -ForegroundColor Green
Write-Host "✅ Antigravity 全局规则已成功写入: $targetFile" -ForegroundColor Green

if (Test-Path $skillSourceFile) {
    Copy-Item -Path $skillSourceFile -Destination "$skillTargetDir\SKILL.md" -Force
    Write-Host "✅ codebase-memory 技能已同步挂载: $skillTargetDir\SKILL.md" -ForegroundColor Cyan
}

if (-not (Get-Command "codebase-memory-mcp" -ErrorAction SilentlyContinue)) {
    Write-Host "⏳ 正在静默安装 codebase-memory-mcp 知识图谱组件..." -ForegroundColor Yellow
    $installScript = Join-Path $env:TEMP "cbm-install.ps1"
    Invoke-RestMethod -Uri "https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1" -OutFile $installScript
    & $installScript -y
    Remove-Item $installScript -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "🔄 正在幂等校验 codebase-memory-mcp 客户端配置挂载..." -ForegroundColor Cyan
    & codebase-memory-mcp install -y
}

if (Test-Path "$HOME\.agents\skills\codebase-memory\SKILL.md") {
    Copy-Item -Path "$HOME\.agents\skills\codebase-memory\SKILL.md" -Destination "$skillTargetDir\SKILL.md" -Force
}

Write-Host "👉 重新打开 Antigravity 或开启新对话即刻生效！" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Green
