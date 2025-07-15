#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Dependency Checker: Validate build dependencies
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

check_dependencies() {
    local deps=(gcc make bash bison gawk patch tar gzip xz)
    for bin in "${deps[@]}"; do
        check_binary_exists "$bin" "$bin not found" || handle_error "$bin missing"
    done
    log_success "All required dependencies are present"
}

main() {
    log_info "Checking build dependencies"
    check_dependencies
    log_success "Dependency check complete"
}

main "$@"
