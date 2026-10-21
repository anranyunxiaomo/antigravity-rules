# Antigravity 中文原生 AI 编程助手核心法则与 MCP 套件

本仓库用于跨设备（macOS / Linux / Windows）一键同步 **Antigravity 全局核心法则 (`~/.gemini/GEMINI.md`)** 并自动部署挂载 **知识图谱检索组件 (`codebase-memory-mcp`)**。

---

## 🚀 新电脑一键初始化

### 1. macOS / Linux
```bash
git clone https://github.com/anranyunxiaomo/antigravity-rules.git ~/.gemini/antigravity-rules && bash ~/.gemini/antigravity-rules/install.sh
```

### 2. Windows (PowerShell)
```powershell
git clone https://github.com/anranyunxiaomo/antigravity-rules.git "$HOME\.gemini\antigravity-rules"; & "$HOME\.gemini\antigravity-rules\install.ps1"
```

---

## 🔄 日常更新同步

### macOS / Linux
```bash
cd ~/.gemini/antigravity-rules && git pull && bash install.sh
```

### Windows (PowerShell)
```powershell
cd "$HOME\.gemini\antigravity-rules"; git pull; .\install.ps1
```

---

## 📦 包含组件说明
- **`GEMINI.md`**：全局 AI 研发核心宪法（已针对 Antigravity `<user_rules>` 24KB 注入阈值优化，100% 零截断完整加载）。
- **`install.sh` / `install.ps1`**：全自动非交互式安装脚本，完成 `~/.gemini/GEMINI.md` 写入及 `codebase-memory-mcp` 二进制安装与客户端幂等挂载。
