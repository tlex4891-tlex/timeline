#!/bin/bash
set -euo pipefail

# ============================================================
# Setup script for syncing global CLAUDE.md from claude-global-config
#
# Usage (run from any repo root):
#   curl -fsSL https://raw.githubusercontent.com/tlex4891-tlex/claude-global-config/main/scripts/setup-claude-global.sh | bash
#
# Or locally:
#   bash scripts/setup-claude-global.sh
# ============================================================

GITHUB_ORG="tlex4891-tlex"
CONFIG_REPO="claude-global-config"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${GITHUB_ORG}/${CONFIG_REPO}/${BRANCH}"

# Detect project root (git root or current dir)
PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_DIR="${PROJECT_DIR}/.claude"
HOOKS_DIR="${CLAUDE_DIR}/hooks"

echo "==> Setting up Claude global config sync in: ${PROJECT_DIR}"

# 1. Create directories
mkdir -p "${HOOKS_DIR}"

# 2. Create session-start hook
cat > "${HOOKS_DIR}/session-start.sh" << 'HOOK_EOF'
#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web (remote environment)
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "==> Syncing global CLAUDE.md from tlex4891-tlex/claude-global-config..."

mkdir -p "$HOME/.claude"

curl -fsSL \
  "https://raw.githubusercontent.com/tlex4891-tlex/claude-global-config/main/CLAUDE.md" \
  -o "$HOME/.claude/CLAUDE.md"

echo "==> CLAUDE.md synced to ~/.claude/CLAUDE.md"
HOOK_EOF

chmod +x "${HOOKS_DIR}/session-start.sh"

# 3. Create or update .claude/settings.json with SessionStart hook
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

if [ -f "${SETTINGS_FILE}" ]; then
  # Check if SessionStart hook already exists
  if grep -q "SessionStart" "${SETTINGS_FILE}"; then
    echo "==> SessionStart hook already configured in settings.json"
  else
    echo "==> WARNING: settings.json exists but has no SessionStart hook."
    echo "    Please manually add the SessionStart hook configuration."
    echo "    See .claude/hooks/session-start.sh for the hook script."
  fi
else
  cat > "${SETTINGS_FILE}" << 'SETTINGS_EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
  echo "==> Created .claude/settings.json with SessionStart hook"
fi

# 4. Create project CLAUDE.md referencing global config
CLAUDE_MD="${PROJECT_DIR}/CLAUDE.md"

if [ ! -f "${CLAUDE_MD}" ] || ! grep -q "claude-global-config" "${CLAUDE_MD}"; then
  cat > "${CLAUDE_MD}" << 'MD_EOF'
# CLAUDE.md

Tento soubor je automaticky synchronizován z [tlex4891-tlex/claude-global-config](https://github.com/tlex4891-tlex/claude-global-config) při každém startu session přes SessionStart hook.

Pro úpravu globálních instrukcí edituj soubor v repozitáři `claude-global-config`.
MD_EOF
  echo "==> Created/updated CLAUDE.md"
else
  echo "==> CLAUDE.md already references claude-global-config"
fi

echo ""
echo "==> Setup complete! Files created/updated:"
echo "    - .claude/settings.json"
echo "    - .claude/hooks/session-start.sh"
echo "    - CLAUDE.md"
echo ""
echo "==> Next steps:"
echo "    1. git add .claude/ CLAUDE.md"
echo "    2. git commit -m 'Add Claude global config sync hooks'"
echo "    3. git push"
