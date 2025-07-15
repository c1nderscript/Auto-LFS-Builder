#!/bin/bash

# Arch Linux Validation Script for Auto-LFS-Builder
# This script validates the Arch Linux system for LFS building

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[ARCH-VALIDATE]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/../config/arch-linux.conf" ]]; then
    source "$SCRIPT_DIR/../config/arch-linux.conf"
fi

# Global validation status
VALIDATION_PASSED=true
VALIDATION_WARNINGS=0

# Utility functions
version_compare() {
    local version1="$1"
    local version2="$2"
    
    if [[ "$version1" == "$version2" ]]; then
        return 0
    fi
    
    local IFS='.'
    local i ver1=($version1) ver2=($version2)
    
    for ((i=0; i<${#ver1[@]} || i<${#ver2[@]}; i++)); do
        if [[ ${ver1[i]:-0} -gt ${ver2[i]:-0} ]]; then
            return 0
        fi
        if [[ ${ver1[i]:-0} -lt ${ver2[i]:-0} ]]; then
            return 1
        fi
    done
    
    return 0
}

check_command() {
    local cmd="$1"
    local package="${2:-$cmd}"
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$cmd is available"
        return 0
    else
        log_error "$cmd is not available (install: sudo pacman -S $package)"
        VALIDATION_PASSED=false
        return 1
    fi
}

# Validation functions
validate_arch_linux() {
    log_info "Validating Arch Linux system..."
    
    if [[ ! -f /etc/arch-release ]]; then
        log_error "This system is not running Arch Linux"
        VALIDATION_PASSED=false
        return 1
    fi
    
    log_success "Running on Arch Linux"
    log_info "System info: $(cat /etc/arch-release)"
    
    # Check if system is up to date
    local last_sync=$(stat -c %Y /var/lib/pacman/sync/core.db 2>/dev/null || echo 0)
    local current_time=$(date +%s)
    local days_since_sync=$(( (current_time - last_sync) / 86400 ))
    
    if [[ $days_since_sync -gt 7 ]]; then
        log_warning "Package database is $days_since_sync days old. Consider running 'sudo pacman -Sy'"
        ((VALIDATION_WARNINGS++))
    fi
    
    return 0
}

validate_kernel() {
    log_info "Validating kernel version..."
    
    local kernel_version=$(uname -r | cut -d'-' -f1)
    local min_version="${MIN_KERNEL_VERSION:-5.4}"
    
    if version_compare "$kernel_version" "$min_version"; then
        log_success "Kernel version $kernel_version is compatible (>= $min_version)"
    else
        log_error "Kernel version $kernel_version is too old (need >= $min_version)"
        VALIDATION_PASSED=false
    fi
    
    # Check for required kernel features
    local required_features=(
        "CONFIG_CGROUPS"
        "CONFIG_NAMESPACES"
        "CONFIG_DEVPTS_MULTIPLE_INSTANCES"
        "CONFIG_FHANDLE"
    )
    
    local kernel_config=""
    for config_path in "/proc/config.gz" "/boot/config-$(uname -r)" "/usr/lib/modules/$(uname -r)/config"; do
        if [[ -f "$config_path" ]]; then
            kernel_config="$config_path"
            break
        fi
    done
    
    if [[ -n "$kernel_config" ]]; then
        log_info "Checking kernel configuration..."
        for feature in "${required_features[@]}"; do
            if zcat "$kernel_config" 2>/dev/null | grep -q "^$feature=y" || \
               cat "$kernel_config" 2>/dev/null | grep -q "^$feature=y"; then
                log_success "$feature is enabled"
            else
                log_warning "$feature may not be enabled"
                ((VALIDATION_WARNINGS++))
            fi
        done
    else
        log_warning "Kernel configuration not found, skipping feature checks"
        ((VALIDATION_WARNINGS++))
    fi
}

validate_glibc() {
    log_info "Validating glibc version..."
    
    local glibc_version=$(ldd --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    local min_version="${MIN_GLIBC_VERSION:-2.31}"
    
    if version_compare "$glibc_version" "$min_version"; then
        log_success "Glibc version $glibc_version is compatible (>= $min_version)"
    else
        log_error "Glibc version $glibc_version is too old (need >= $min_version)"
        VALIDATION_PASSED=false
    fi
    
    # Check for required glibc features
    if ldconfig -p | grep -q "libpthread.so"; then
        log_success "POSIX threads support available"
    else
        log_error "POSIX threads support not found"
        VALIDATION_PASSED=false
    fi
}

validate_gcc() {
    log_info "Validating GCC version..."
    
    if ! check_command "gcc" "gcc"; then
        return 1
    fi
    
    local gcc_version=$(gcc -dumpversion)
    local min_version="${MIN_GCC_VERSION:-9.0}"
    
    if version_compare "$gcc_version" "$min_version"; then
        log_success "GCC version $gcc_version is compatible (>= $min_version)"
    else
        log_error "GCC version $gcc_version is too old (need >= $min_version)"
        VALIDATION_PASSED=false
    fi
    
    # Check for required GCC features
    if gcc -v 2>&1 | grep -q "enable-languages=.*c++"; then
        log_success "C++ support available"
    else
        log_warning "C++ support may not be available"
        ((VALIDATION_WARNINGS++))
    fi
    
    # Check for LTO support
    if gcc -v 2>&1 | grep -q "enable-lto"; then
        log_success "LTO support available"
    else
        log_info "LTO support not available (not required)"
    fi
}

validate_build_tools() {
    log_info "Validating build tools..."
    
    local required_tools=(
        "make:make"
        "ld:binutils"
        "as:binutils"
        "strip:binutils"
        "bison:bison"
        "flex:flex"
        "gawk:gawk"
        "m4:m4"
        "texinfo:texinfo"
        "patch:patch"
        "tar:tar"
        "gzip:gzip"
        "xz:xz"
        "sed:sed"
        "grep:grep"
        "find:findutils"
        "sort:coreutils"
        "uniq:coreutils"
        "head:coreutils"
        "tail:coreutils"
        "cut:coreutils"
        "tr:coreutils"
        "wc:coreutils"
    )
    
    for tool_spec in "${required_tools[@]}"; do
        local tool=${tool_spec%%:*}
        local package=${tool_spec##*:}
        check_command "$tool" "$package"
    done
}

validate_python() {
    log_info "Validating Python installation..."
    
    if ! check_command "python" "python"; then
        return 1
    fi
    
    local python_version=$(python --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
    if version_compare "$python_version" "3.6"; then
        log_success "Python version $python_version is compatible (>= 3.6)"
    else
        log_error "Python version $python_version is too old (need >= 3.6)"
        VALIDATION_PASSED=false
    fi
    
    # Check for python3 symlink
    if [[ -L /usr/bin/python3 ]] || [[ -f /usr/bin/python3 ]]; then
        log_success "python3 symlink available"
    else
        log_warning "python3 symlink not found, some scripts may fail"
        ((VALIDATION_WARNINGS++))
    fi
    
    # Check for pip
    if check_command "pip" "python-pip"; then
        log_success "pip is available"
    fi
}

validate_system_resources() {
    log_info "Validating system resources..."
    
    # Check disk space
    local available_space=$(df / | awk 'NR==2 {print $4}')
    local required_space_kb=$(( ${MIN_DISK_SPACE_GB:-50} * 1024 * 1024 ))
    
    if [[ "$available_space" -gt "$required_space_kb" ]]; then
        log_success "Sufficient disk space available ($(( available_space / 1024 / 1024 ))GB)"
    else
        log_error "Insufficient disk space (need at least ${MIN_DISK_SPACE_GB:-50}GB)"
        VALIDATION_PASSED=false
    fi
    
    # Check memory
    local available_memory=$(free -m | awk 'NR==2{print $2}')
    local recommended_memory="${RECOMMENDED_RAM_MB:-4096}"
    
    if [[ "$available_memory" -gt "$recommended_memory" ]]; then
        log_success "Sufficient memory available (${available_memory}MB)"
    else
        log_warning "Low memory available (${available_memory}MB), recommended: ${recommended_memory}MB"
        ((VALIDATION_WARNINGS++))
    fi
    
    # Check CPU cores
    local cpu_cores=$(nproc)
    if [[ "$cpu_cores" -gt 1 ]]; then
        log_success "Multi-core CPU detected ($cpu_cores cores)"
    else
        log_warning "Single-core CPU detected, build will be slow"
        ((VALIDATION_WARNINGS++))
    fi
}

validate_arch_packages() {
    log_info "Validating required Arch packages..."
    
    local missing_packages=()
    
    # Check required packages
    for package in "${REQUIRED_PACKAGES_ARCH[@]}"; do
        if ! pacman -Qi "$package" &>/dev/null; then
            missing_packages+=("$package")
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        log_error "Missing required packages: ${missing_packages[*]}"
        log_info "Install with: sudo pacman -S ${missing_packages[*]}"
        VALIDATION_PASSED=false
    else
        log_success "All required packages are installed"
    fi
    
    # Check optional packages
    local missing_optional=()
    for package in "${OPTIONAL_PACKAGES_ARCH[@]}"; do
        if ! pacman -Qi "$package" &>/dev/null; then
            missing_optional+=("$package")
        fi
    done
    
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        log_info "Missing optional packages: ${missing_optional[*]}"
        log_info "Install with: sudo pacman -S ${missing_optional[*]}"
    fi
}

validate_multilib() {
    log_info "Validating multilib configuration..."
    
    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        log_success "Multilib repository is enabled"
        
        # Check for multilib packages
        if pacman -Qi lib32-glibc &>/dev/null; then
            log_success "32-bit glibc is installed"
        else
            log_info "32-bit glibc not installed (may be needed for some packages)"
        fi
    else
        log_info "Multilib repository is disabled (enable for 32-bit support)"
    fi
}

validate_aur_access() {
    log_info "Validating AUR access..."
    
    local aur_helpers=("yay" "paru" "trizen" "yaourt")
    local found_helper=""
    
    for helper in "${aur_helpers[@]}"; do
        if command -v "$helper" &> /dev/null; then
            found_helper="$helper"
            break
        fi
    done
    
    if [[ -n "$found_helper" ]]; then
        log_success "AUR helper available: $found_helper"
    else
        log_info "No AUR helper found (yay or paru recommended)"
    fi
    
    # Check for base-devel (required for building AUR packages)
    if pacman -Qi base-devel &>/dev/null; then
        log_success "base-devel is installed"
    else
        log_warning "base-devel not installed (required for AUR packages)"
        ((VALIDATION_WARNINGS++))
    fi
}

validate_performance_tools() {
    log_info "Validating performance tools..."
    
    # Check ccache
    if command -v ccache &> /dev/null; then
        log_success "ccache is available"
        
        local ccache_size=$(ccache -s | grep "max cache size" | awk '{print $4" "$5}' || echo "unknown")
        log_info "ccache max size: $ccache_size"
    else
        log_info "ccache not available (install for faster rebuilds)"
    fi
    
    # Check distcc
    if command -v distcc &> /dev/null; then
        log_success "distcc is available"
    else
        log_info "distcc not available (install for distributed compilation)"
    fi
    
    # Check for SSD
    if [[ -b /dev/nvme0n1 ]]; then
        log_success "NVMe SSD detected"
    elif [[ -b /dev/sda ]] && [[ $(cat /sys/block/sda/queue/rotational) -eq 0 ]]; then
        log_success "SSD detected"
    else
        log_info "Traditional HDD detected (SSD recommended for faster builds)"
    fi
}

validate_network() {
    log_info "Validating network connectivity..."
    
    # Check internet connectivity
    if ping -c 1 archlinux.org &> /dev/null; then
        log_success "Internet connectivity available"
    else
        log_error "No internet connectivity (required for downloading packages)"
        VALIDATION_PASSED=false
    fi
    
    # Check package repository access
    if curl -s --head https://archlinux.org/packages/ | grep -q "200 OK"; then
        log_success "Arch package repository accessible"
    else
        log_warning "Arch package repository may not be accessible"
        ((VALIDATION_WARNINGS++))
    fi
}

# Main validation function
run_validation() {
    log_info "Starting comprehensive Arch Linux validation for LFS building"
    echo
    
    # Run all validation checks
    validate_arch_linux
    validate_kernel
    validate_glibc
    validate_gcc
    validate_build_tools
    validate_python
    validate_system_resources
    validate_arch_packages
    validate_multilib
    validate_aur_access
    validate_performance_tools
    validate_network
    
    echo
    log_info "Validation complete"
    
    # Summary
    if [[ "$VALIDATION_PASSED" == "true" ]]; then
        log_success "All critical validation checks passed"
        if [[ $VALIDATION_WARNINGS -gt 0 ]]; then
            log_warning "$VALIDATION_WARNINGS warnings found (see above)"
        fi
        return 0
    else
        log_error "Validation failed - please address the errors above"
        return 1
    fi
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_validation
fi
