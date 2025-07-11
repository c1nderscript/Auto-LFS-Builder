#!/bin/bash
# Package management helpers

PACKAGES_DIR="${PACKAGES_DIR:-packages}"
BUILD_DIR="${BUILD_DIR:-build}"
mkdir -p "$PACKAGES_DIR" "$BUILD_DIR"

download_package() {
    local package_name="$1"
    local package_url="$2"
    local checksum="$3"

    log_info "Downloading $package_name"
    wget -c "$package_url" -O "${PACKAGES_DIR}/${package_name}" || handle_error "Failed to download $package_name"
    verify_checksum "${PACKAGES_DIR}/${package_name}" "$checksum" || handle_error "Checksum failed for $package_name"
}

verify_checksum() {
    local file="$1"
    local expected="$2"
    echo "$expected  $file" | sha256sum -c - >/dev/null 2>&1
}

extract_package() {
    local package_name="$1"
    log_info "Extracting $package_name"
    tar -xf "${PACKAGES_DIR}/${package_name}" -C "$BUILD_DIR" || handle_error "Failed to extract $package_name"
}

build_package() {
    local package_name="$1"
    local build_function="$2"

    log_info "Building $package_name"
    extract_package "$package_name"
    local dir_name="${package_name%.tar.*}"
    cd "$BUILD_DIR/$dir_name" || handle_error "Missing build directory for $package_name"
    "$build_function" || handle_error "Build failed for $package_name"
    cd - > /dev/null
}
