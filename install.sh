#!/usr/bin/env bash
set -e

GEMINI_DIR="$HOME/.gemini"
TARGET_FILE="$GEMINI_DIR/GEMINI.md"
SKILLS_TARGET_DIR="$GEMINI_DIR/config/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/GEMINI.md"
SKILLS_SOURCE_DIR="$SCRIPT_DIR/skills"
CBM_BIN="$HOME/.local/bin/codebase-memory-mcp"

mkdir -p "$GEMINI_DIR" "$SKILLS_TARGET_DIR"
cp -f "$SOURCE_FILE" "$TARGET_FILE"
echo "✅ Antigravity 全局规则已成功写入: $TARGET_FILE"

if [ -d "$SKILLS_SOURCE_DIR" ]; then
  skill_count=0
  for skill_path in "$SKILLS_SOURCE_DIR"/*; do
    if [ -d "$skill_path" ]; then
      skill_name="$(basename "$skill_path")"
      target_skill="$SKILLS_TARGET_DIR/$skill_name"
      # 若目标不存在、是失效软链、或为普通目录则覆盖同步；若为有效外部软链（如 skills-manager）则保留
      if [ ! -e "$target_skill" ] || [ ! -L "$target_skill" ]; then
        rm -rf "$target_skill"
        cp -R "$skill_path" "$target_skill"
      fi
      skill_count=$((skill_count + 1))
    fi
  done
  echo "✅ 已全量校验并同步 $skill_count 个高阶 Skills 至: $SKILLS_TARGET_DIR"
fi

if [ ! -f "$CBM_BIN" ]; then
  echo "⏳ 正在静默安装 codebase-memory-mcp 知识图谱组件..."
  curl -fsSL https://raw.githubusercontent.com/DeusData/codebase-memory-mcp/main/install.sh | bash -s -- -y
else
  echo "🔄 正在幂等校验 codebase-memory-mcp 客户端配置..."
  "$CBM_BIN" install -y >/dev/null 2>&1 || true
fi

if [ -f "$HOME/.agents/skills/codebase-memory/SKILL.md" ]; then
  mkdir -p "$SKILLS_TARGET_DIR/codebase-memory"
  cp -f "$HOME/.agents/skills/codebase-memory/SKILL.md" "$SKILLS_TARGET_DIR/codebase-memory/SKILL.md"
fi

# 强制幂等注入 Antigravity 专属 mcp_config.json（修复官方安装器未识别 Antigravity 的问题）
python3 - "$CBM_BIN" << 'EOF'
import json, os, sys

cbm_bin = sys.argv[1]
home = os.path.expanduser("~")
config_paths = [
    os.path.join(home, ".gemini", "antigravity", "mcp_config.json"),
    os.path.join(home, ".gemini", "config", "mcp_config.json"),
    os.path.join(home, ".gemini", "antigravity-ide", "mcp_config.json"),
]

for path in config_paths:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = {}
    if os.path.exists(path):
        try:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read().strip()
                if content:
                    data = json.loads(content)
        except Exception:
            data = {}
    if not isinstance(data, dict):
        data = {}
    servers = data.setdefault("mcpServers", {})
    servers["codebase-memory-mcp"] = {
        "command": cbm_bin,
        "args": []
    }
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
EOF

echo "✅ codebase-memory-mcp 已成功注入 Antigravity MCP 配置文件"
echo "👉 重新打开 Antigravity 或开启新对话即刻生效！"
