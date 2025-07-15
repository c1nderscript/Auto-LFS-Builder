#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Package Tester: Test individual packages
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

# Basic package sanity test referencing LFS/BLFS requirements
# Usage: test_package <package>

test_package() {
    local pkg="$1"
    case "$pkg" in
        bash)
            bash --version >/dev/null 2>&1 || handle_error "bash test failed"
            ;;
        gcc)
            gcc --version >/dev/null 2>&1 || handle_error "gcc test failed"
            ;;
        make)
            make --version >/dev/null 2>&1 || handle_error "make test failed"
            ;;
        *)
            check_binary_exists "$pkg" "$pkg binary not found" || handle_error "$pkg missing"
            "$pkg" --version >/dev/null 2>&1 || handle_error "$pkg --version failed"
            ;;
    esac
    log_success "$pkg passed basic tests"
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
