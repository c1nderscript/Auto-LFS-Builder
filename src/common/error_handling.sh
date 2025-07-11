#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Error handling utilities

handle_error() {
    local msg="$1"
    log_error "$msg"
    exit 1
}

# Log script exit status
on_exit() {
    local status=$?
    if [ $status -ne 0 ]; then
        log_error "Script aborted with status $status"
    else
        log_success "Script completed successfully"
    fi
}

# Trap unexpected errors and script exit
trap 'handle_error "An error occurred on line $LINENO"' ERR
trap on_exit EXIT

