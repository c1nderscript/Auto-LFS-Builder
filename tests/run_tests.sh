#!/bin/bash
set -euo pipefail

# Indicate we are running in CI to bypass heavy checks
export CI=true

# basic unit test for validation_suite functions
source generated/validation_suite.sh

check_binary_exists bash "bash missing"
if check_binary_exists nonexistent_binary "should fail"; then
    echo "check_binary_exists should have failed" >&2
    exit 1
fi

# run Python unit tests
python -m pytest -q tests

echo "All unit tests passed"
