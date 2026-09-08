#!/usr/bin/env bash
set -e
GEMINI_DIR="$HOME/.gemini"
TARGET_FILE="$GEMINI_DIR/GEMINI.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/GEMINI.md"

mkdir -p "$GEMINI_DIR"
cp -f "$SOURCE_FILE" "$TARGET_FILE"
echo "✅ Antigravity 全局规则已成功写入: $TARGET_FILE"
echo "👉 重新打开 Antigravity 或开启新对话即刻生效！"
