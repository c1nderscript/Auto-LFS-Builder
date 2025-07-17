#!/bin/bash
set -euo pipefail

# Indicate we are running in CI to bypass heavy checks
export CI=true

# basic unit test for validation_suite functions

# Ensure generated directory exists
mkdir -p generated

# Copy validation suite if it doesn't exist
if [[ ! -f generated/validation_suite.sh ]]; then
    cp scripts/templates/validation_suite.sh.template generated/validation_suite.sh
fi

# Source validation suite functions without running main
# Strip the final invocation to allow sourcing in CI environments
source <(grep -v 'main \"\$@\"' generated/validation_suite.sh)

check_binary_exists bash "bash missing"
if check_binary_exists nonexistent_binary "should fail"; then
    echo "check_binary_exists should have failed" >&2
    exit 1
fi

# run Python unit tests
python -m pytest -q tests

echo "All unit tests passed"
