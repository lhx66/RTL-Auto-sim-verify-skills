#!/bin/sh
# install_skills.sh — 全局一键安装脚本 (Global Installer for RTL Verification Copilot)
#
# 用法:
#   在终端中运行以下命令，即可直接从远程 Git 仓库全局安装或更新此 Skill 库：
#   curl -fsSL https://raw.githubusercontent.com/lhx66/RTL-Auto-sim-verify-skills/main/install_skills.sh | sh
#
# 功能:
#   1. 将远程仓库克隆/更新至全局统一存放路径 ~/.agents/skills/rtl-verification-copilot
#   2. 自动建立软链接分发到各全局 AI 平台（Claude Code, Codex, Cursor 等）
#   3. 自动在 Claude Code 中注册原生的 /rtl-verify 斜杠命令

set -eu

# ---------------------------------------------------------------------------
# 常量定义
# ---------------------------------------------------------------------------
REPO_URL="${RTL_VERIFY_REPO_URL:-https://github.com/lhx66/RTL-Auto-sim-verify-skills.git}"
SKILL_NAME="rtl-verification-copilot"
CANONICAL_DIR="$HOME/.agents/skills/$SKILL_NAME"

# ---------------------------------------------------------------------------
# 终端颜色输出
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

info()    { printf "${BLUE}[INFO]${NC}  %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }

# ---------------------------------------------------------------------------
# 全局平台自动检测
# ---------------------------------------------------------------------------
detect_global_platforms() {
    platforms=""
    if [ -d "$HOME/.claude" ]; then platforms="$platforms claude-code"; fi
    if [ -d "$HOME/.gemini" ]; then platforms="$platforms gemini"; fi
    if [ -n "${CODEX_HOME:-}" ] || [ -d "$HOME/.codex" ]; then platforms="$platforms codex"; fi
    if [ -d "$HOME/.cursor" ]; then platforms="$platforms cursor"; fi
    if [ -d "$HOME/.config/goose" ]; then platforms="$platforms goose"; fi
    echo "$platforms"
}

# ---------------------------------------------------------------------------
# 解析平台存放路径
# ---------------------------------------------------------------------------
platform_path() {
    case "$1" in
        claude-code) echo "$HOME/.claude/skills/$SKILL_NAME" ;;
        gemini)      echo "$HOME/.gemini/skills/$SKILL_NAME" ;;
        codex)       echo "${CODEX_HOME:-$HOME/.codex}/skills/$SKILL_NAME" ;;
        cursor)      echo "$HOME/.cursor/rules/$SKILL_NAME" ;;
        goose)       echo "$HOME/.config/goose/skills/$SKILL_NAME" ;;
    esac
}

# ---------------------------------------------------------------------------
# 友好名称
# ---------------------------------------------------------------------------
platform_display() {
    case "$1" in
        claude-code) echo "Claude Code" ;;
        gemini)      echo "Gemini CLI" ;;
        codex)       echo "Codex System" ;;
        cursor)      echo "Cursor Rules" ;;
        goose)       echo "Goose Agent" ;;
    esac
}

# ---------------------------------------------------------------------------
# 创建软链接 (失败时降级为复制)
# ---------------------------------------------------------------------------
create_symlink() {
    target="$1"
    link_path="$2"
    if [ "$target" = "$link_path" ]; then return 0; fi
    mkdir -p "$(dirname "$link_path")"
    if [ -e "$link_path" ] || [ -L "$link_path" ]; then rm -rf "$link_path"; fi
    if ln -s "$target" "$link_path" 2>/dev/null; then
        return 0
    else
        cp -R "$target" "$link_path"
    fi
}

# ---------------------------------------------------------------------------
# 主执行流程
# ---------------------------------------------------------------------------
main() {
    printf "\n${BOLD}RTL Verification Copilot — 全局一键安装程序${NC}\n\n"

    if ! command -v git >/dev/null 2>&1; then
        warn "未检测到 git 环境，请先安装 git 后再运行此脚本。"
        exit 1
    fi

    # 1. 拉取核心代码库
    if [ -d "$CANONICAL_DIR/.git" ]; then
        info "正在从远程同步最新 Skill 代码..."
        cd "$CANONICAL_DIR"
        git remote set-url origin "$REPO_URL"
        git fetch origin main
        git reset --hard origin/main
    else
        info "正在将远程 Skill 仓库克隆到全局目录: $CANONICAL_DIR"
        mkdir -p "$(dirname "$CANONICAL_DIR")"
        rm -rf "$CANONICAL_DIR"
        git clone "$REPO_URL" "$CANONICAL_DIR"
    fi

    # 2. 生成标准 Skill 入口，并清理旧版非标准入口
    cp "$CANONICAL_DIR/skills/SKILL.template.md" "$CANONICAL_DIR/skills/SKILL.md"
    info "正在清理旧版 Agent 插件元数据..."
    rm -f "$CANONICAL_DIR/skills/marketplace.json"
    success "Skill 核心文件部署成功。"

    # =======================================================================
    # 3. [核心新增功能] 为 Claude Code 注册系统级斜杠命令
    # =======================================================================
    if [ -d "$HOME/.claude" ]; then
        info "正在为 Claude Code 生成 /rtl-verify 快捷指令..."
        mkdir -p "$HOME/.claude/commands"
        cat > "$HOME/.claude/commands/rtl-verify.md" << EOF
---
description: 启动 RTL Verification Orchestrator 全自动验证飞轮
---

请先读取并严格遵循 \`~/.agents/skills/rtl-verification-copilot/skills/Master_Skill_RTL_Copilot.md\` 中的统筹引擎守则。

然后，接管当前目录下的代码 \$ARGUMENTS，启动全自动 RTL 验证飞轮。
开始前，请先帮我梳理当前工程的顶层模块结构，并向我强制确认设计意图。
EOF
        success "斜杠命令注册成功: /rtl-verify"
    fi
    # =======================================================================

    # 4. 自动软链接分发
    platforms="$(detect_global_platforms)"
    installed=""
    count=0
    TARGET_SKILLS_DIR="$CANONICAL_DIR/skills"

    for platform in $platforms; do
        dest="$(platform_path "$platform")"
        create_symlink "$TARGET_SKILLS_DIR" "$dest"
        name="$(platform_display "$platform")"
        success "已成功分发软链接至 $name → $dest"
        installed="$installed $name,"
        count=$((count + 1))
    done

    # ---------------------------------------------------------------------------
    # 安装完成总结
    # ---------------------------------------------------------------------------
    printf "\n${BOLD}恭喜！安装/更新圆满完成！${NC}\n\n"

    printf "${BOLD}💡 如何在项目中使用：${NC}\n"
    printf "  1. 打开终端，进入您的任意 RTL 工程目录\n"
    printf "  2. 运行 'claude' 启动 AI 助手\n"
    printf "  3. 在对话框中直接输入以下斜杠命令（支持跟上文件名参数）：\n\n"
    printf "    ${YELLOW}/rtl-verify core.v peripheral.v${NC}\n\n"
    printf "  验证飞轮将瞬间启动接管！\n\n"
}

main
