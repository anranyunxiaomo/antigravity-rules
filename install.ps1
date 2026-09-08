# Antigravity 规则本地安装脚本 (Windows PowerShell)
$ErrorActionPreference = "Stop"

$geminiDir = "$HOME\.gemini"
$targetFile = "$geminiDir\GEMINI.md"
$sourceFile = "$PSScriptRoot\GEMINI.md"

if (-not (Test-Path $geminiDir)) {
    New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
}

Copy-Item -Path $sourceFile -Destination $targetFile -Force
Write-Host "=============================================" -ForegroundColor Green
Write-Host "✅ Antigravity 全局规则已成功写入：" -ForegroundColor Green
Write-Host "   $targetFile" -ForegroundColor Cyan
Write-Host "👉 重新打开 Antigravity 或开启新对话即刻生效！" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Green
