# Antigravity 规则、全量 Skills 与 MCP 本地安装脚本 (Windows PowerShell)
$ErrorActionPreference = "Stop"

$geminiDir = "$HOME\.gemini"
$targetFile = "$geminiDir\GEMINI.md"
$skillsTargetDir = "$geminiDir\config\skills"
$sourceFile = "$PSScriptRoot\GEMINI.md"
$skillsSourceDir = "$PSScriptRoot\skills"

New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
New-Item -ItemType Directory -Force -Path $skillsTargetDir | Out-Null

Copy-Item -Path $sourceFile -Destination $targetFile -Force
Write-Host "=============================================" -ForegroundColor Green
Write-Host "✅ Antigravity 全局规则已成功写入: $targetFile" -ForegroundColor Green

if (Test-Path $skillsSourceDir) {
    $skillDirs = Get-ChildItem -Path $skillsSourceDir -Directory
    foreach ($dir in $skillDirs) {
        $destPath = Join-Path $skillsTargetDir $dir.Name
        if (Test-Path $destPath) {
            Remove-Item -Path $destPath -Recurse -Force
        }
        Copy-Item -Path $dir.FullName -Destination $destPath -Recurse -Force
    }
    Write-Host "✅ 已全量同步 $($skillDirs.Count) 个高阶 Skills 至: $skillsTargetDir" -ForegroundColor Cyan
}

if (-not (Get-Command "codebase-memory-mcp" -ErrorAction SilentlyContinue)) {
    Write-Host "⏳ 正在静默安装 codebase-memory-mcp 知识图谱组件..." -ForegroundColor Yellow
    $installScript = Join-Path $env:TEMP "cbm-install.ps1"
    Invoke-RestMethod -Uri "https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.ps1" -OutFile $installScript
    & $installScript -y
    Remove-Item $installScript -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "🔄 正在幂等校验 codebase-memory-mcp 客户端配置..." -ForegroundColor Cyan
    & codebase-memory-mcp install -y | Out-Null
}

if (Test-Path "$HOME\.agents\skills\codebase-memory\SKILL.md") {
    $cbmSkillDir = Join-Path $skillsTargetDir "codebase-memory"
    New-Item -ItemType Directory -Force -Path $cbmSkillDir | Out-Null
    Copy-Item -Path "$HOME\.agents\skills\codebase-memory\SKILL.md" -Destination "$cbmSkillDir\SKILL.md" -Force
}

# 定位 codebase-memory-mcp.exe 路径并强制注入 Antigravity 的 mcp_config.json
$cbmCmd = Get-Command "codebase-memory-mcp" -ErrorAction SilentlyContinue
$cbmBin = if ($cbmCmd) { $cbmCmd.Source } else { "$HOME\.local\bin\codebase-memory-mcp.exe" }

$configPaths = @(
    "$geminiDir\antigravity\mcp_config.json",
    "$geminiDir\config\mcp_config.json",
    "$geminiDir\antigravity-ide\mcp_config.json"
)

foreach ($cfgPath in $configPaths) {
    $cfgDir = Split-Path -Parent $cfgPath
    New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null
    $jsonObj = @{}
    if (Test-Path $cfgPath) {
        try {
            $raw = Get-Content -Path $cfgPath -Raw -Encoding UTF8
            if ($raw -and $raw.Trim().Length -gt 0) {
                $parsed = $raw | ConvertFrom-Json
                foreach ($prop in $parsed.PSObject.Properties) {
                    $jsonObj[$prop.Name] = $prop.Value
                }
            }
        } catch {
            $jsonObj = @{}
        }
    }
    if (-not $jsonObj.ContainsKey("mcpServers") -or $null -eq $jsonObj["mcpServers"]) {
        $jsonObj["mcpServers"] = @{}
    } else {
        $serversHash = @{}
        foreach ($prop in $jsonObj["mcpServers"].PSObject.Properties) {
            $serversHash[$prop.Name] = $prop.Value
        }
        $jsonObj["mcpServers"] = $serversHash
    }
    $jsonObj["mcpServers"]["codebase-memory-mcp"] = @{
        command = $cbmBin
        args    = @()
    }
    $jsonObj | ConvertTo-Json -Depth 10 | Set-Content -Path $cfgPath -Encoding UTF8
}

Write-Host "✅ codebase-memory-mcp 已成功注入 Antigravity MCP 配置文件" -ForegroundColor Green
Write-Host "👉 重新打开 Antigravity 或开启新对话即刻生效！" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Green
