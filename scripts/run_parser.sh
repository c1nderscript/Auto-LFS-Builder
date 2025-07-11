#!/usr/bin/env bash
# Run the Auto-LFS documentation parser
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
DOCS_DIR="$ROOT_DIR/docs"
PARSER_SCRIPT="$ROOT_DIR/src/parsers/lfs_parser.py"

if [ -x "$PARSER_SCRIPT" ]; then
    echo "[Parser] Running documentation parser..."
    python3 "$PARSER_SCRIPT" "$DOCS_DIR"
else
    echo "[Parser] Parser script not found ($PARSER_SCRIPT). Skipping."
fi
