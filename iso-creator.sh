#!/bin/bash
# Auto-LFS-Builder ISO Creation Script
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Create ISO image from the built LFS system
create_iso_image() {
    local volume_name="${1:-${ISO_VOLUME:-AUTO_LFS}}"
    local boot_cfg="${2:-${BOOTLOADER_CFG:-}}"
    local output_path="${3:-${ISO_OUTPUT:-auto-lfs.iso}}"
    local build_root="${4:-${LFS:-/mnt/lfs}}"
    
    log_info "Creating bootable ISO image"
    log_info "Volume name: $volume_name"
    log_info "Output path: $output_path"
    log_info "Build root: $build_root"
    
    # Validate build root exists
    if [[ ! -d "$build_root" ]]; then
        log_error "Build root $build_root not found"
        return 1
    fi
    
    # Check if we have a kernel
    if ! compgen -G "$build_root/boot/vmlinuz*" > /dev/null; then
        log_warning "No kernel found in $build_root/boot/"
        log_info "Creating minimal boot structure"
        mkdir -p "$build_root/boot"
        # Create a placeholder kernel info file
        echo "LFS System - Kernel not included" > "$build_root/boot/kernel_info.txt"
    fi
    
    # Copy bootloader configuration if provided
    if [[ -n "$boot_cfg" && -f "$boot_cfg" ]]; then
        log_info "Using bootloader config: $boot_cfg"
        mkdir -p "$build_root/boot"
        cp "$boot_cfg" "$build_root/boot/" || {
            log_error "Failed to copy bootloader configuration"
            return 1
        }
    fi
    
    # Create output directory
    mkdir -p "$(dirname "$output_path")"
    
    # Create ISO using available tools
    if command -v xorriso >/dev/null 2>&1; then
        log_info "Creating ISO with xorriso"
        xorriso -as mkisofs \
            -R -J -V "$volume_name" \
            -o "$output_path" \
            "$build_root" || {
            log_error "xorriso failed to create ISO"
            return 1
        }
    elif command -v genisoimage >/dev/null 2>&1; then
        log_info "Creating ISO with genisoimage"
        genisoimage -R -J -V "$volume_name" \
            -o "$output_path" \
            "$build_root" || {
            log_error "genisoimage failed to create ISO"
            return 1
        }
        
        # Make it hybrid bootable if possible
        if command -v isohybrid >/dev/null 2>&1; then
            log_info "Making ISO hybrid bootable"
            isohybrid "$output_path" || log_warning "isohybrid failed"
        fi
    else
        log_error "Neither xorriso nor genisoimage is installed"
        log_error "Please install one of these tools to create ISO images:"
        log_error "  Ubuntu/Debian: sudo apt-get install xorriso"
        log_error "  Fedora/RHEL: sudo dnf install xorriso"
        log_error "  Arch: sudo pacman -S libisoburn"
        return 1
    fi
    
    # Check if ISO was created successfully
    if [[ -f "$output_path" ]]; then
        local iso_size=$(du -h "$output_path" | cut -f1)
        log_success "ISO image created successfully!"
        log_success "Location: $output_path"
        log_success "Size: $iso_size"
        return 0
    else
        log_error "ISO creation failed - file not found"
        return 1
    fi
}

# Main function
main() {
    log_info "Auto-LFS-Builder ISO Creator"
    
    # Parse arguments
    local volume_name="${1:-}"
    local boot_cfg="${2:-}"
    local output_path="${3:-}"
    local build_root="${4:-}"
    
    # Set defaults from environment or use sensible defaults
    volume_name="${volume_name:-${ISO_VOLUME:-AUTO_LFS}}"
    boot_cfg="${boot_cfg:-${BOOTLOADER_CFG:-}}"
    output_path="${output_path:-${ISO_OUTPUT:-${LFS_WORKSPACE:-$HOME/lfs-workspace}/auto-lfs.iso}}"
    build_root="${build_root:-${LFS:-${LFS_WORKSPACE:-$HOME/lfs-workspace}/lfs}}"
    
    # Create the ISO
    create_iso_image "$volume_name" "$boot_cfg" "$output_path" "$build_root"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
