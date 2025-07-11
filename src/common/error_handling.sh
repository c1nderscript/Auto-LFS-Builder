#!/bin/bash
# Error handling helpers

handle_error() {
    local exit_code=$?
    local msg="$1"
    log_error "$msg (exit code: $exit_code)"
    exit $exit_code
}

# Trap common signals and errors
trap 'handle_error "Error on line $LINENO"' ERR
trap 'log_error "Build interrupted"; exit 1' INT
