#!/bin/bash
# Package management utilities

PACKAGES_DIR="${PACKAGES_DIR:-packages}"
BUILD_DIR="${BUILD_DIR:-build}"
mkdir -p "$PACKAGES_DIR" "$BUILD_DIR"

# Ensure required binaries are present
check_binary_exists() {
    local bin="$1"
    local err_msg="$2"
    command -v "$bin" >/dev/null 2>&1 || handle_error "$err_msg"
}

verify_checksum() {
    local file="$1"
    local checksum="$2"
    echo "$checksum  $file" | sha256sum -c - || handle_error "Checksum verification failed for $file"
}

extract_package() {
    local package="$1"
    tar -xf "${PACKAGES_DIR}/${package}" -C "$BUILD_DIR" || handle_error "Failed to extract ${package}"
}

download_package() {
    local package_name="$1"
    local package_url="$2"
    local checksum="$3"

    log_info "Downloading $package_name"
    wget -c "$package_url" -O "${PACKAGES_DIR}/${package_name}" || handle_error "Download failed for $package_name"
    verify_checksum "${PACKAGES_DIR}/${package_name}" "$checksum"
}

build_package() {
    local package_name="$1"
    local build_function="$2"

    log_info "Building $package_name"
    extract_package "$package_name"
    cd "${BUILD_DIR}/${package_name%.tar*}" || handle_error "Build directory missing for $package_name"
    "$build_function" || handle_error "Build failed for $package_name"
    cd - > /dev/null
}

