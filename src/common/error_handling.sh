#!/bin/bash
# Error handling utilities

handle_error() {
    local msg="$1"
    log_error "$msg"
    exit 1
}

check_binary_exists() {
    local bin="$1"
    local err_msg="$2"
    command -v "$bin" >/dev/null 2>&1 || handle_error "$err_msg"
}

