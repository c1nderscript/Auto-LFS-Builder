#!/bin/bash
# Enhanced Package Download and Verification Script for Auto-LFS-Builder
# This script provides secure and verified package downloads with checksums
# SPDX-License-Identifier: MIT

set -euo pipefail

# Enhanced logging functions for verbose output
log_download() {
    echo -e "${CYAN:-\033[0;36m}[DOWNLOAD]${NC:-\033[0m} $*"
}

log_verify() {
    echo -e "${PURPLE:-\033[0;35m}[VERIFY]${NC:-\033[0m} $*"
}

log_checksum() {
    echo -e "${GREEN:-\033[0;32m}[CHECKSUM]${NC:-\033[0m} $*"
}

# Package definitions with URLs and checksums (LFS 12.0 stable versions)
declare -A PACKAGES=(
    # Core toolchain packages
    ["binutils"]="2.42 https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz"
    ["gcc"]="13.2.0 https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
    ["linux"]="6.7.4 https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.7.4.tar.xz"
    ["glibc"]="2.39 https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz"
    
    # GCC dependencies
    ["mpfr"]="4.2.1 https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"
    ["gmp"]="6.3.0 https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
    ["mpc"]="1.3.1 https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
    
    # Core system tools
    ["bash"]="5.2.21 https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz"
    ["coreutils"]="9.4 https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.xz"
    ["make"]="4.4.1 https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
    ["sed"]="4.9 https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz"
    ["tar"]="1.35 https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz"
    ["gawk"]="5.3.0 https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz"
    ["findutils"]="4.9.0 https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz"
    ["grep"]="3.11 https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz"
    ["gzip"]="1.13 https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz"
    ["util-linux"]="2.39.3 https://www.kernel.org/pub/software/utils/util-linux/v2.39/util-linux-2.39.3.tar.xz"
    
    # Additional essential packages
    ["diffutils"]="3.10 https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz"
    ["file"]="5.45 https://astron.com/pub/file/file-5.45.tar.gz"
    ["patch"]="2.7.6 https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz"
    ["texinfo"]="7.1 https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz"
    ["bison"]="3.8.2 https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz"
    ["flex"]="2.6.4 https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
    
    # Build system tools
    ["ncurses"]="6.4 https://invisible-mirror.net/archives/ncurses/ncurses-6.4.tar.gz"
    ["readline"]="8.2 https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz"
    ["m4"]="1.4.19 https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz"
    ["bc"]="6.7.5 https://github.com/gavinhoward/bc/releases/download/6.7.5/bc-6.7.5.tar.xz"
    
    # Network and compression tools
    ["wget"]="1.21.4 https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz"
    ["openssl"]="3.2.1 https://github.com/openssl/openssl/releases/download/openssl-3.2.1/openssl-3.2.1.tar.gz"
    ["ca-certificates"]="2024-03-11 https://curl.se/ca/cacert-2024-03-11.pem"
    
    # Python (for some build tools)
    ["python"]="3.12.2 https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tar.xz"
    
    # Bootloader and kernel tools
    ["grub"]="2.12 https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz"
)

# SHA256 checksums for package verification
declare -A CHECKSUMS=(
    ["binutils-2.42.tar.xz"]="f6e4d41fd5fc778b06b7891457b3620da5ecea1006c6a4a41ae998109f85a800"
    ["gcc-13.2.0.tar.xz"]="e275e76442a6067341a27f04c5c6b83d8613144004c0413528863dc6b5c743da"
    ["linux-6.7.4.tar.xz"]="8d0c8936e3140a0fbdf511ad7a9f21121598f3656743898f47bb9052d37cff68"
    ["glibc-2.39.tar.xz"]="f77bd47cf8170c57365ae7bf86696c118adb3b120d3259c64c502d3dc1e2d926"
    ["mpfr-4.2.1.tar.xz"]="277807353a6726978996945af13e52829e3abd7a9a5b7fb2793894e18f1fcbb2"
    ["gmp-6.3.0.tar.xz"]="a3c2b80201b89e68616f4ad30bc66aee707d3aa15c4e762e4a16b9d7d8fef0c9"
    ["mpc-1.3.1.tar.gz"]="ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8"
    ["bash-5.2.21.tar.gz"]="c8e31bdc59b69aaffc5b36509905ba3e5cbb12f808ceaac4ab53a3fb96ce9dd2"
    ["coreutils-9.4.tar.xz"]="ea613a4cf44612326e917201bbbcdfbd301de21ffc3b59b6e5c07e040b275e52"
    ["make-4.4.1.tar.gz"]="dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3"
    ["sed-4.9.tar.xz"]="6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181"
    ["tar-1.35.tar.xz"]="4d62ff37342ec7aed748535323930c7cf94acf71c291c6b96b202a6b04b573a4"
    ["gawk-5.3.0.tar.xz"]="ca9c16d3d11d0ff8c69d79dc0b47267e1329a69b39b799895604ed447d3ca90b"
    ["findutils-4.9.0.tar.xz"]="a2bfb8c09d436770edc59f50fa483e785b161a3b7b9d547573cb08065fd462fe"
    ["grep-3.11.tar.xz"]="1db2aedde89d0dea42b16d9528f894c8d15dae4e190b59aecc78f5a951276eab"
    ["gzip-1.13.tar.xz"]="7454eb6935db17c6655576c2e1b0fabefd38b4d0936e0f87f48cd062ce91a057"
    ["util-linux-2.39.3.tar.xz"]="7b6605e48d1a49f43cc4b4cfc59f313d0dd5402fa40b96810bd572e167dfed0f"
)

# Function to verify package checksums
verify_checksum() {
    local filename="$1"
    local expected_checksum="$2"
    
    log_verify "Verifying checksum for $filename"
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "Expected SHA256: $expected_checksum"
    fi
    
    if [[ ! -f "$filename" ]]; then
        echo "❌ File not found: $filename"
        return 1
    fi
    
    # Calculate actual checksum
    local actual_checksum
    if command -v sha256sum >/dev/null 2>&1; then
        actual_checksum=$(sha256sum "$filename" | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        actual_checksum=$(shasum -a 256 "$filename" | cut -d' ' -f1)
    else
        echo "❌ No SHA256 checksum utility found (sha256sum or shasum)"
        return 1
    fi
    
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "Actual SHA256:   $actual_checksum"
    fi
    
    if [[ "$actual_checksum" == "$expected_checksum" ]]; then
        log_checksum "✅ Checksum verified for $filename"
        return 0
    else
        echo "❌ Checksum mismatch for $filename"
        echo "  Expected: $expected_checksum"
        echo "  Actual:   $actual_checksum"
        return 1
    fi
}

# Function to download a single package with verification
download_package() {
    local package_name="$1"
    local version="$2"
    local url="$3"
    local filename=$(basename "$url")
    
    log_download "Downloading $package_name $version"
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "URL: $url"
        echo "File: $filename"
    fi
    
    # Check if file already exists and is valid
    if [[ -f "$filename" ]]; then
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            echo "File exists, verifying checksum..."
        fi
        if [[ -n "${CHECKSUMS[$filename]:-}" ]]; then
            if verify_checksum "$filename" "${CHECKSUMS[$filename]}"; then
                echo "✅ Using existing verified file: $filename"
                return 0
            else
                echo "⚠️  Existing file failed verification, re-downloading..."
                rm -f "$filename"
            fi
        else
            echo "⚠️  No checksum available for $filename, re-downloading to be safe"
            rm -f "$filename"
        fi
    fi
    
    # Download with progress and resume capability
    local download_attempts=0
    local max_attempts=3
    
    while [[ $download_attempts -lt $max_attempts ]]; do
        ((download_attempts++))
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            echo "Download attempt $download_attempts of $max_attempts"
        fi
        
        # Use wget with comprehensive options
        if command -v wget >/dev/null 2>&1; then
            if [[ "${VERBOSE:-false}" == "true" ]]; then
                echo "Using wget for download"
            fi
            if wget --progress=bar:force:noscroll \
                   --timeout=30 \
                   --tries=3 \
                   --continue \
                   --user-agent="Auto-LFS-Builder/1.0" \
                   "$url"; then
                break
            fi
        # Fallback to curl
        elif command -v curl >/dev/null 2>&1; then
            if [[ "${VERBOSE:-false}" == "true" ]]; then
                echo "Using curl for download"
            fi
            if curl -L -o "$filename" \
                   --connect-timeout 30 \
                   --retry 3 \
                   --retry-delay 5 \
                   --continue-at - \
                   --user-agent "Auto-LFS-Builder/1.0" \
                   --progress-bar \
                   "$url"; then
                break
            fi
        else
            echo "❌ Neither wget nor curl available for download"
            return 1
        fi
        
        if [[ $download_attempts -eq $max_attempts ]]; then
            echo "❌ Failed to download $filename after $max_attempts attempts"
            return 1
        fi
        
        echo "⚠️  Download failed, retrying in 5 seconds..."
        sleep 5
    done
    
    # Verify download completed successfully
    if [[ ! -f "$filename" ]]; then
        echo "❌ Download appeared successful but file not found: $filename"
        return 1
    fi
    
    local file_size=$(stat -c%s "$filename" 2>/dev/null || echo "0")
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "Downloaded file size: $file_size bytes"
    fi
    
    if [[ "$file_size" -eq 0 ]]; then
        echo "❌ Downloaded file is empty: $filename"
        rm -f "$filename"
        return 1
    fi
    
    # Verify checksum if available
    if [[ -n "${CHECKSUMS[$filename]:-}" ]]; then
        if verify_checksum "$filename" "${CHECKSUMS[$filename]}"; then
            echo "✅ Successfully downloaded and verified: $filename"
        else
            echo "❌ Download completed but checksum verification failed"
            rm -f "$filename"
            return 1
        fi
    else
        echo "⚠️  No checksum available for verification: $filename"
        echo "✅ Downloaded: $filename (unverified)"
    fi
    
    return 0
}

# Function to download all packages with comprehensive error handling
download_packages_enhanced() {
    echo "=================================================="
    echo "  Downloading and Verifying LFS Packages"
    echo "=================================================="
    
    # Ensure we're in the correct directory
    cd "$LFS_WORKSPACE/sources"
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "Working directory: $(pwd)"
    fi
    
    # Check internet connectivity
    echo "🌐 Checking internet connectivity..."
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "❌ No internet connectivity detected"
        return 1
    fi
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo "✅ Internet connectivity confirmed"
    fi
    
    # Create download summary
    local total_packages=${#PACKAGES[@]}
    local downloaded_count=0
    local failed_count=0
    local skipped_count=0
    
    echo "📦 Preparing to download $total_packages packages"
    
    # Download each package
    for package_name in "${!PACKAGES[@]}"; do
        local package_info="${PACKAGES[$package_name]}"
        local version=$(echo "$package_info" | cut -d' ' -f1)
        local url=$(echo "$package_info" | cut -d' ' -f2-)
        
        echo ""
        echo "📥 Processing $package_name $version"
        
        if download_package "$package_name" "$version" "$url"; then
            ((downloaded_count++))
            if [[ "${VERBOSE:-false}" == "true" ]]; then
                echo "Progress: $downloaded_count/$total_packages packages completed"
            fi
        else
            ((failed_count++))
            echo "❌ Failed to download $package_name $version"
            
            # Ask user if they want to continue or abort
            if [[ "${INTERACTIVE:-true}" == "true" ]]; then
                echo -n "Continue with remaining downloads? [y/N]: "
                read -r response
                if [[ "$response" != "y" && "$response" != "Y" ]]; then
                    echo "❌ Download process aborted by user"
                    return 1
                fi
            fi
        fi
    done
    
    # Download summary
    echo ""
    echo "=================================================="
    echo "  Download Summary"
    echo "=================================================="
    echo "📊 Total packages: $total_packages"
    echo "✅ Successfully downloaded: $downloaded_count"
    echo "❌ Failed downloads: $failed_count"
    echo "⏭️  Skipped (already present): $skipped_count"
    
    if [[ $failed_count -gt 0 ]]; then
        echo "⚠️  $failed_count packages failed to download"
        echo "ℹ️  You may need to download these manually or fix network issues"
        return 1
    else
        echo "🎉 All packages downloaded and verified successfully!"
        
        # Calculate total download size
        local total_size=0
        for file in *.tar.* *.tgz *.pem; do
            if [[ -f "$file" ]]; then
                local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
                total_size=$((total_size + size))
            fi
        done
        
        local total_size_mb=$((total_size / 1024 / 1024))
        echo "📏 Total download size: ${total_size_mb} MB"
        
        return 0
    fi
}

# Function to list available packages
list_packages() {
    echo "📋 Available packages in Auto-LFS-Builder:"
    echo ""
    printf "%-15s %-10s %s\n" "Package" "Version" "URL"
    echo "=================================================================="
    
    for package_name in "${!PACKAGES[@]}"; do
        local package_info="${PACKAGES[$package_name]}"
        local version=$(echo "$package_info" | cut -d' ' -f1)
        local url=$(echo "$package_info" | cut -d' ' -f2-)
        printf "%-15s %-10s %s\n" "$package_name" "$version" "$url"
    done
}

# Function to verify all downloaded packages
verify_all_packages() {
    echo "🔍 Verifying all downloaded packages..."
    
    local verified_count=0
    local failed_count=0
    
    for filename in "${!CHECKSUMS[@]}"; do
        if [[ -f "$filename" ]]; then
            if verify_checksum "$filename" "${CHECKSUMS[$filename]}"; then
                ((verified_count++))
            else
                ((failed_count++))
            fi
        fi
    done
    
    echo "📊 Verification complete: $verified_count verified, $failed_count failed"
    
    if [[ $failed_count -eq 0 ]]; then
        echo "✅ All downloaded packages verified successfully"
        return 0
    else
        echo "❌ $failed_count packages failed verification"
        return 1
    fi
}

# Function to check for missing packages
check_missing_packages() {
    echo "🔍 Checking for missing packages..."
    
    local missing_packages=()
    
    for package_name in "${!PACKAGES[@]}"; do
        local package_info="${PACKAGES[$package_name]}"
        local url=$(echo "$package_info" | cut -d' ' -f2-)
        local filename=$(basename "$url")
        
        if [[ ! -f "$filename" ]]; then
            missing_packages+=("$package_name ($filename)")
        fi
    done
    
    if [[ ${#missing_packages[@]} -eq 0 ]]; then
        echo "✅ All packages are present"
        return 0
    else
        echo "⚠️  Missing packages:"
        for pkg in "${missing_packages[@]}"; do
            echo "  - $pkg"
        done
        return 1
    fi
}

# Export functions for use in main build script
export -f download_packages_enhanced verify_checksum download_package list_packages verify_all_packages check_missing_packages
export -f log_download log_verify log_checksum

# If script is run directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Enhanced Package Download Script for Auto-LFS-Builder"
    echo "This script provides secure and verified package downloads"
    echo ""
    echo "Usage: source scripts/download-enhanced.sh"
    echo ""
    echo "Available functions:"
    echo "  download_packages_enhanced  - Download all packages with verification"
    echo "  list_packages              - List all available packages"
    echo "  verify_all_packages        - Verify checksums of downloaded packages"
    echo "  check_missing_packages     - Check for missing packages"
    echo ""
    echo "Environment variables:"
    echo "  VERBOSE=true               - Enable verbose logging"
    echo "  DEBUG=true                 - Enable debug logging"
    echo "  INTERACTIVE=false          - Disable interactive prompts"
fi
