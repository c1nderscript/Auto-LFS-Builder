#!/bin/bash
# ISO Creator: Generate bootable ISO image
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

create_iso_image() {
    # Generate ISO using xorriso referencing docs/blfs-git
    log_info "Building ISO image with xorriso" || true
    mkdir -pv iso/rootfs || handle_error "create iso dir"
    cp -a $LFS/* iso/rootfs/ || handle_error "copy rootfs"
    xorriso -as mkisofs -o lfs.iso -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
        -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot \
        -boot-load-size 4 -boot-info-table iso || handle_error "create iso"
}

main() {
    log_info "Creating bootable ISO"
    create_iso_image
    log_success "ISO image creation complete"
}

main "$@"
