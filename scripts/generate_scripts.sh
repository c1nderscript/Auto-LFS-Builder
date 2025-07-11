#!/usr/bin/env bash
# Generate build scripts from parsed documentation
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
GENERATED_DIR="$ROOT_DIR/generated"
GENERATE_SCRIPT="$ROOT_DIR/src/builders/master_builder.sh"

mkdir -p "$GENERATED_DIR"

if [ -x "$GENERATE_SCRIPT" ]; then
    echo "[Generator] Generating build scripts..."
    bash "$GENERATE_SCRIPT" "$GENERATED_DIR"
else
    echo "[Generator] Build generator not found ($GENERATE_SCRIPT). Skipping."
fi
