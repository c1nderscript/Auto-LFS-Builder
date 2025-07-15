#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Dependency Checker: Validate build dependencies
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh
source generated/validation_suite.sh

check_dependencies() {
    local deps=(wget tar gcc make)
    for bin in "${deps[@]}"; do
        check_binary_exists "$bin" "$bin not found" || return 1
    done
}

main() {
    log_info "Checking build dependencies"
    check_dependencies
    log_success "Dependency check complete"
}

main "$@"
