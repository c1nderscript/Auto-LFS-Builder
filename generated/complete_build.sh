#!/bin/bash
# Auto-LFS-Builder Master Build Script
# Redirects to the main build script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/../lfs-build.sh"

if [[ -f "$MAIN_SCRIPT" ]]; then
    echo "Starting Auto-LFS-Builder..."
    exec bash "$MAIN_SCRIPT" "$@"
else
    echo "Error: Main build script not found at $MAIN_SCRIPT"
    exit 1
fi
