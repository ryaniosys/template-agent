#!/usr/bin/env bash
# Session lifecycle hook for crash-safe ephemeral data.
#
# Usage:
#   hook_session_lifecycle.sh start   -- run at session start (SessionStart hook)
#   hook_session_lifecycle.sh end     -- run at session end (SessionEnd hook)
#
# Reads `data_dir` from config.local.yaml. Falls back to ./data/ if not set.
# Skills write ephemeral artifacts to DATA_ROOT/<skill-name>/.
# A .heartbeat file in DATA_ROOT detects unclean shutdowns (crashes).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${REPO_ROOT}/config.local.yaml"

# ---------------------------------------------------------------------------
# Resolve data_dir from config.local.yaml
# ---------------------------------------------------------------------------
resolve_data_dir() {
    local data_dir=""

    if [ -f "$CONFIG_FILE" ]; then
        # Extract data_dir value (handles both quoted and unquoted YAML values)
        data_dir=$(grep -E '^\s*data_dir\s*:' "$CONFIG_FILE" \
            | head -1 \
            | sed 's/^[^:]*:\s*//' \
            | sed 's/^["'"'"']//' \
            | sed 's/["'"'"']$//' \
            | sed 's/\s*#.*//' \
            | xargs)
    fi

    # Expand ~ to $HOME
    data_dir="${data_dir/#\~/$HOME}"

    # Fallback to repo-local data/ directory
    if [ -z "$data_dir" ]; then
        data_dir="${REPO_ROOT}/data"
    fi

    echo "$data_dir"
}

# ---------------------------------------------------------------------------
# Resolve memory_backup_dir from config.local.yaml
# ---------------------------------------------------------------------------
resolve_memory_backup_dir() {
    local mem_dir=""

    if [ -f "$CONFIG_FILE" ]; then
        mem_dir=$(grep -E '^\s*memory_backup_dir\s*:' "$CONFIG_FILE" \
            | head -1 \
            | sed 's/^[^:]*:\s*//' \
            | sed 's/^["'"'"']//' \
            | sed 's/["'"'"']$//' \
            | sed 's/\s*#.*//' \
            | xargs)
    fi

    # Expand ~ to $HOME
    mem_dir="${mem_dir/#\~/$HOME}"

    echo "$mem_dir"
}

# ---------------------------------------------------------------------------
# Ensure Claude Code memory dir is symlinked to backup location
# ---------------------------------------------------------------------------
ensure_memory_symlink() {
    local backup_dir
    backup_dir="$(resolve_memory_backup_dir)"

    # Skip if not configured
    if [ -z "$backup_dir" ]; then
        return
    fi

    # Derive the Claude Code project dir name from the repo path
    # ~/.claude/projects/ encodes paths: / and _ replaced with -
    local project_name
    project_name=$(echo "$REPO_ROOT" | tr '/_' '--')
    local memory_dir="$HOME/.claude/projects/${project_name}/memory"
    local target_dir="${backup_dir}/${project_name}"

    # Already a symlink — nothing to do
    if [ -L "$memory_dir" ]; then
        return
    fi

    mkdir -p "$target_dir"

    # If memory dir exists with files, move them to backup first
    if [ -d "$memory_dir" ]; then
        cp -a "$memory_dir"/* "$target_dir/" 2>/dev/null || true
        rm -rf "$memory_dir"
    fi

    # Create symlink
    ln -s "$target_dir" "$memory_dir"
    echo "Memory backed up: ${memory_dir} -> ${target_dir}"
}

# ---------------------------------------------------------------------------
# SessionStart: check for stale heartbeat, write new one
# ---------------------------------------------------------------------------
session_start() {
    local data_dir
    data_dir="$(resolve_data_dir)"

    mkdir -p "$data_dir"

    # Ensure memory backup symlink
    ensure_memory_symlink

    local heartbeat="${data_dir}/.heartbeat"

    if [ -f "$heartbeat" ]; then
        local last_ts
        last_ts=$(cat "$heartbeat")
        echo "WARNING: Previous session did not end cleanly (started ${last_ts})."
        echo "Check ${data_dir}/ for unsaved artifacts or partial state."
    fi

    # Write new heartbeat with ISO 8601 timestamp
    date -u +"%Y-%m-%dT%H:%M:%SZ" > "$heartbeat"
    echo "Session started. Heartbeat written to ${heartbeat}"
}

# ---------------------------------------------------------------------------
# SessionEnd: flush /tmp artifacts to data_dir, clear heartbeat
# ---------------------------------------------------------------------------
session_end() {
    local data_dir
    data_dir="$(resolve_data_dir)"

    mkdir -p "$data_dir"

    local heartbeat="${data_dir}/.heartbeat"

    # Flush /tmp skill artifacts if a staging directory exists.
    # Skills should write to /tmp/<repo-name>-session/<skill-name>/ during
    # the session. This hook copies everything to the persistent data_dir.
    local repo_name
    repo_name=$(basename "$REPO_ROOT")
    local tmp_staging="/tmp/${repo_name}-session"

    if [ -d "$tmp_staging" ]; then
        echo "Flushing staged artifacts from ${tmp_staging} to ${data_dir}..."
        # Copy skill subdirectories, preserving structure
        for skill_dir in "${tmp_staging}"/*/; do
            if [ -d "$skill_dir" ]; then
                local skill_name
                skill_name=$(basename "$skill_dir")
                mkdir -p "${data_dir}/${skill_name}"
                cp -r "${skill_dir}"* "${data_dir}/${skill_name}/" 2>/dev/null || true
                echo "  Flushed: ${skill_name}/"
            fi
        done
        # Clean up staging directory
        rm -rf "$tmp_staging"
    fi

    # Clear heartbeat
    if [ -f "$heartbeat" ]; then
        rm "$heartbeat"
        echo "Session ended. Heartbeat cleared."
    else
        echo "Session ended (no heartbeat found)."
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
case "${1:-}" in
    start)
        session_start
        ;;
    end)
        session_end
        ;;
    *)
        echo "Usage: $0 {start|end}"
        exit 1
        ;;
esac
