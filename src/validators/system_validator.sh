#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# System Validator: Validate complete system
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

validate_system() {
    log_info "Checking core LFS utilities"
    local bins=(bash gcc ld make gawk bison diff)
    for b in "${bins[@]}"; do
        check_binary_exists "$b" "$b missing" || handle_error "$b missing"
    done

    [ -f /lib/x86_64-linux-gnu/libc.so.6 ] || handle_error "glibc not installed"

    if [ "${ENABLE_GNOME:-false}" = "true" ]; then
        log_info "Checking GNOME desktop components"
        check_binary_exists gnome-session "GNOME session not found" || handle_error "gnome-session missing"
    fi

    log_success "System validation checks passed"
}

main() {
    log_info "Validating final system"
    validate_system
    log_success "System validation complete"
}

main "$@"
