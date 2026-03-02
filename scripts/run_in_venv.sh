#!/usr/bin/env bash
#
# Run Python scripts in an isolated venv.
# Creates/reuses venv in /tmp, installs requirements on first run.
#
# Usage:
#   ./run_in_venv.sh script.py [args...]
#   echo '{"foo": "bar"}' | ./run_in_venv.sh script.py -
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="$(basename "$(dirname "$SCRIPT_DIR")")"
VENV_DIR="/tmp/${REPO_NAME}-venv"
REQUIREMENTS="$SCRIPT_DIR/requirements.txt"

# Create venv if it doesn't exist
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating venv at $VENV_DIR..." >&2
    python3 -m venv "$VENV_DIR"
fi

# Install/update requirements if requirements.txt is newer than marker
MARKER="$VENV_DIR/.requirements-installed"
if [[ -f "$REQUIREMENTS" ]] && { [[ ! -f "$MARKER" ]] || [[ "$REQUIREMENTS" -nt "$MARKER" ]]; }; then
    echo "Installing requirements..." >&2
    "$VENV_DIR/bin/pip" install -q -r "$REQUIREMENTS"
    touch "$MARKER"
fi

# Run the script
SCRIPT="$1"
shift

# Handle relative paths
if [[ ! "$SCRIPT" = /* ]]; then
    SCRIPT="$SCRIPT_DIR/$SCRIPT"
fi

exec "$VENV_DIR/bin/python" "$SCRIPT" "$@"
