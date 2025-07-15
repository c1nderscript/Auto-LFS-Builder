#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# ISO Creator: Generate bootable ISO image
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

create_iso_image() {
    # Create a bootable ISO image from the built system.
    # Arguments: [volume-name] [bootloader-config] [output-path]

    local volume_name="${1:-${ISO_VOLUME:-AUTO_LFS}}"
    local boot_cfg="${2:-${BOOTLOADER_CFG:-}}"
    local output_path="${3:-${ISO_OUTPUT:-auto-lfs.iso}}"
    local build_root="${BUILD_ROOT:-${LFS:-/mnt/lfs}}"

    [ -d "$build_root" ] || handle_error "Build root $build_root not found"

    if [ -n "$boot_cfg" ] && [ -f "$boot_cfg" ]; then
        log_info "Using bootloader config $boot_cfg"
        mkdir -p "$build_root/boot"
        cp "$boot_cfg" "$build_root/boot/" || \
            handle_error "Failed to copy bootloader configuration"
    fi

    mkdir -p "$(dirname "$output_path")"

    if command -v xorriso >/dev/null 2>&1; then
        log_info "Generating ISO with xorriso"
        xorriso -as mkisofs -R -J -V "$volume_name" \
            -o "$output_path" "$build_root" || \
            handle_error "xorriso failed to create ISO"
    elif command -v genisoimage >/dev/null 2>&1; then
        log_info "Generating ISO with genisoimage"
        genisoimage -R -J -V "$volume_name" -o "$output_path" \
            "$build_root" || handle_error "genisoimage failed"
        if command -v isohybrid >/dev/null 2>&1; then
            isohybrid "$output_path" || log_warning "isohybrid failed"
        fi
    else
        handle_error "Neither xorriso nor genisoimage is installed"
    fi
}

main() {
    log_info "Creating bootable ISO"
    create_iso_image "$@"
    log_success "ISO image creation complete"
}

main "$@"
