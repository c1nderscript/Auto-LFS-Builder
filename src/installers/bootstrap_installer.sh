#!/bin/bash
# Bootstrap Installer: Hardware detection and installation
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

run_installer() {
    # Detect hardware and launch automated installation
    log_info "Detecting hardware" || true
    lshw -short || handle_error "hardware detection"

    log_info "Starting automated installation" || true
    bash src/installers/partition_manager.sh || handle_error "partitioning"
    bash src/builders/master_builder.sh || handle_error "system build"
    bash src/installers/iso_creator.sh || handle_error "iso creation"
}

main() {
    log_info "Running bootstrap installer"
    run_installer
    log_success "Bootstrap installation complete"
}

main "$@"
