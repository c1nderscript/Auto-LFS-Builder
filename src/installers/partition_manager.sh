#!/bin/bash
# Partition Manager: Automatic disk partitioning
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

create_partitions() {
    # Use parted to create standard LFS partitions
    log_info "Creating LFS partitions" || true
    parted --script /dev/sda \
        mklabel gpt \
        mkpart primary ext4 1MiB 511MiB \
        mkpart primary ext4 511MiB 100% || handle_error "partition disk"
    mkfs.ext4 /dev/sda2 || handle_error "format root"
    mkfs.fat -F32 /dev/sda1 || handle_error "format boot"
}

main() {
    log_info "Partitioning disks"
    create_partitions
    log_success "Disk partitioning complete"
}

main "$@"
