#!/usr/bin/env bash
# PostToolUse hook: back up non-git config files when Claude edits them.
#
# Many agent setups rely on config files outside git (shell scripts, dotfiles,
# system configs). This hook watches for Write/Edit operations on those paths
# and copies the file to a persistent, file-synced backup directory.
#
# Setup:
#   1. Set `backup_dir` in config.local.yaml to a synced folder
#   2. Uncomment the PostToolUse entry in .claude/hooks.json
#   3. Add your paths to the SYNC_MAP or pattern sections below
#
# The hook is a no-op if backup_dir is not configured.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${REPO_ROOT}/config.local.yaml"

# ---------------------------------------------------------------------------
# Read file path from PostToolUse hook stdin
# ---------------------------------------------------------------------------
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

# Resolve symlinks to canonical path
FILE_PATH=$(realpath -m "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")

# ---------------------------------------------------------------------------
# Resolve backup_dir from config.local.yaml
# ---------------------------------------------------------------------------
resolve_backup_dir() {
    local dir=""

    if [ -f "$CONFIG_FILE" ]; then
        dir=$(grep -E '^\s*backup_dir\s*:' "$CONFIG_FILE" \
            | head -1 \
            | sed 's/^[^:]*:\s*//' \
            | sed 's/^["'"'"']//' \
            | sed 's/["'"'"']$//' \
            | sed 's/\s*#.*//' \
            | xargs)
    fi

    dir="${dir/#\~/$HOME}"
    echo "$dir"
}

BACKUP_DIR="$(resolve_backup_dir)"

# No backup_dir configured — nothing to do
[ -z "$BACKUP_DIR" ] && exit 0

# ---------------------------------------------------------------------------
# Exact file matches (add your specific files here)
# ---------------------------------------------------------------------------
declare -A SYNC_MAP=(
    # Examples (uncomment and adapt):
    # ["$HOME/.claude/settings.json"]="$BACKUP_DIR/claude/settings.json"
    # ["$HOME/.claude/settings.local.json"]="$BACKUP_DIR/claude/settings.local.json"
    # ["$HOME/CLAUDE.md"]="$BACKUP_DIR/claude/CLAUDE.md"
)

if [[ ${#SYNC_MAP[@]} -gt 0 ]] && [[ -v SYNC_MAP["$FILE_PATH"] ]]; then
    DEST="${SYNC_MAP[$FILE_PATH]}"
    mkdir -p "$(dirname "$DEST")"
    cp "$FILE_PATH" "$DEST"
    exit 0
fi

# ---------------------------------------------------------------------------
# Pattern matches (add directory-level patterns here)
# ---------------------------------------------------------------------------

# Custom scripts in ~/.local/bin/
# Only fires when Claude edits a file here, so pip-installed binaries are safe.
if [[ "$FILE_PATH" =~ ^$HOME/.local/bin/([^/]+)$ ]]; then
    DEST="$BACKUP_DIR/bin/${BASH_REMATCH[1]}"
    mkdir -p "$(dirname "$DEST")"
    cp "$FILE_PATH" "$DEST"
    exit 0
fi

# Claude global skills: ~/.claude/skills/*/SKILL.md
# if [[ "$FILE_PATH" =~ ^$HOME/.claude/skills/([^/]+)/SKILL\.md$ ]]; then
#     DEST="$BACKUP_DIR/claude/skills/${BASH_REMATCH[1]}/SKILL.md"
#     mkdir -p "$(dirname "$DEST")"
#     cp "$FILE_PATH" "$DEST"
#     exit 0
# fi

# Claude hooks: ~/.claude/hooks/*.sh
# if [[ "$FILE_PATH" =~ ^$HOME/.claude/hooks/([^/]+\.sh)$ ]]; then
#     DEST="$BACKUP_DIR/claude/hooks/${BASH_REMATCH[1]}"
#     mkdir -p "$(dirname "$DEST")"
#     cp "$FILE_PATH" "$DEST"
#     exit 0
# fi

exit 0
