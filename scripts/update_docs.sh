#!/usr/bin/env bash
# Update LFS documentation sources from their git repositories.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Update LFS book
git -C "$ROOT_DIR/docs/lfs" pull origin master

# Update BLFS book
git -C "$ROOT_DIR/docs/blfs" pull origin master

# Update JHALFS
git -C "$ROOT_DIR/docs/jhalfs" pull origin master

