#!/bin/bash
set -euo pipefail

# CI/CD Testing Environment variables from SETUP.md
export LFS="/tmp/lfs-ci-build"
export BUILD_PROFILE="minimal"
export PARALLEL_JOBS="2"
export PARSING_LOG_LEVEL="DEBUG"
export VALIDATION_MODE="permissive"
export GNOME_ENABLED="false"
export NETWORKING_ENABLED="true"
export VERIFY_PACKAGES="false"
export CHECKSUM_VALIDATION="sha256"

# Ensure generated directory exists
mkdir -p generated

# Copy validation suite if it doesn't exist
if [[ ! -f generated/validation_suite.sh ]]; then
    cp scripts/templates/validation_suite.sh.template generated/validation_suite.sh
fi

# Run validation suite
bash generated/validation_suite.sh
