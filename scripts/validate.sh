#!/usr/bin/env bash
# Validate generated build scripts and environment
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
VALIDATOR_SCRIPT="$ROOT_DIR/src/validators/system_validator.sh"

if [ -x "$VALIDATOR_SCRIPT" ]; then
    echo "[Validator] Validating generated scripts..."
    bash "$VALIDATOR_SCRIPT" "$ROOT_DIR/generated"
else
    echo "[Validator] Validation script not found ($VALIDATOR_SCRIPT). Skipping."
fi
