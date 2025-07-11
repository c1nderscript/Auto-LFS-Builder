#!/bin/bash
# Master Builder: Orchestrates complete system build
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../common/logging.sh"
source "${SCRIPT_DIR}/../common/error_handling.sh"
source "${SCRIPT_DIR}/../common/package_management.sh"

main() {
    log_info "Starting master build process"
    bash "${SCRIPT_DIR}/lfs_builder.sh"
    bash "${SCRIPT_DIR}/networking_builder.sh"
    bash "${SCRIPT_DIR}/gnome_builder.sh"
    bash "${SCRIPT_DIR}/blfs_builder.sh"
    log_success "Master build completed successfully"
}

main "$@"
