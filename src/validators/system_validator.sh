#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# System Validator: Validate complete system
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh
source generated/validation_suite.sh

validate_system() {
    validate_lfs_system || return 1
    if [ "${GNOME_ENABLED:-false}" = "true" ]; then
        validate_gnome_desktop || return 1
    fi
}

main() {
    log_info "Validating final system"
    validate_system
    log_success "System validation complete"
}

main "$@"
