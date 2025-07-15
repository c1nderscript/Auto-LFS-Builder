#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Package Tester: Test individual packages
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh
source generated/validation_suite.sh

# Basic package sanity test referencing LFS/BLFS requirements
# Usage: test_package <package>

test_package() {
    local pkg="${1:-}"
    if [ -z "$pkg" ]; then
        log_error "No package specified"
        return 1
    fi

    check_binary_exists "$pkg" "$pkg not installed" || return 1
    "$pkg" --version >/dev/null 2>&1 || {
        log_error "$pkg failed to run"
        return 1
    }
}

main() {
    if [ "$#" -eq 0 ]; then
        handle_error "No package specified"
    fi
    log_info "Testing packages"
    for pkg in "$@"; do
        test_package "$pkg"
    done
    log_success "Package testing complete"
}

main "$@"
