# Antigravity 规则与 MCP 本地安装脚本 (Windows PowerShell)
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

if (-not (Get-Command "codebase-memory-mcp" -ErrorAction SilentlyContinue)) {
    Write-Host "⏳ 正在安装 codebase-memory-mcp 知识图谱组件..." -ForegroundColor Yellow
    irm https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1 | iex
}

Write-Host "👉 重新打开 Antigravity 或开启新对话即刻生效！" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Green
