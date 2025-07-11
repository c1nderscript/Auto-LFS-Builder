#!/bin/bash
# Complete Build: orchestrates full LFS, networking, GNOME, and BLFS build
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

main() {
    log_info "Starting complete build process"
    bash src/builders/lfs_builder.sh
    bash src/builders/networking_builder.sh
    bash src/builders/gnome_builder.sh
    bash src/builders/blfs_builder.sh
    log_success "Complete build finished successfully"
}

main "$@"

