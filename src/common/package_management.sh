#!/bin/bash
# Common package management functions

PACKAGES_DIR=${PACKAGES_DIR:-packages}
BUILD_DIR=${BUILD_DIR:-build}

# Download a package with checksum verification
# Usage: download_package name url checksum
download_package() {
    local name="$1"
    local url="$2"
    local checksum="$3"

    mkdir -p "$PACKAGES_DIR"
    log_info "Downloading $name"
    wget -c "$url" -O "$PACKAGES_DIR/$name" || handle_error "Failed to download $name"
    verify_checksum "$PACKAGES_DIR/$name" "$checksum" || handle_error "Checksum mismatch for $name"
}

# Verify SHA256 checksum
# Usage: verify_checksum file expected_checksum
verify_checksum() {
    local file="$1"
    local expected="$2"

    echo "$expected  $file" | sha256sum -c - >/dev/null 2>&1
}

# Extract a package archive
# Usage: extract_package name
extract_package() {
    local name="$1"

    mkdir -p "$BUILD_DIR"
    log_info "Extracting $name"
    tar -xf "$PACKAGES_DIR/$name" -C "$BUILD_DIR" || handle_error "Failed to extract $name"
}
