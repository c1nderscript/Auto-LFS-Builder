#!/bin/bash
# Dependency Checker: Validate build dependencies
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

check_dependencies() {
    # Verify required build tools are present
    log_info "Verifying essential tools" || true
    local tools=(gcc make bash tar xz)
    for t in "${tools[@]}"; do
        command -v "$t" >/dev/null || handle_error "missing $t"
    done
}

main() {
    log_info "Checking build dependencies"
    check_dependencies
    log_success "Dependency check complete"
}

main "$@"
