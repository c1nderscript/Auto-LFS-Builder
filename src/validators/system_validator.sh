#!/bin/bash
# System Validator: Validate complete system
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

validate_system() {
    log_info "Checking essential binaries" || true
    local bins=(/bin/bash /usr/bin/gcc /usr/bin/gnome-session)
    for b in "${bins[@]}"; do
        [ -x "$b" ] || handle_error "missing binary $b"
    done

    log_info "Validating network connectivity" || true
    ping -c1 8.8.8.8 >/dev/null || handle_error "network unreachable"
}

main() {
    log_info "Validating final system"
    validate_system
    log_success "System validation complete"
}

main "$@"
