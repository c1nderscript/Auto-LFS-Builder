#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Comprehensive validation suite for Auto-LFS-Builder
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Basic logging helpers
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }

# Check if a binary exists in PATH
check_binary_exists() {
    local bin="$1"
    local msg="$2"
    if ! command -v "$bin" >/dev/null 2>&1; then
        log_error "$msg ($bin not found)"
        return 1
    else
        log_success "$bin found"
        return 0
    fi
}

# Check system requirements
check_system_requirements() {
    log_info "Checking system requirements..."
    
    # Check OS
    if [[ "$(uname -s)" != "Linux" ]]; then
        log_error "This script requires Linux"
        return 1
    fi
    
    # Check architecture
    local arch=$(uname -m)
    if [[ "$arch" != "x86_64" && "$arch" != "aarch64" ]]; then
        log_warning "Architecture $arch may not be fully supported"
    fi
    
    # Check disk space
    local workspace="${LFS_WORKSPACE:-$HOME/lfs-workspace}"
    local available_space=$(df "$workspace" 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)
    local required_space=52428800  # 50GB in KB
    
    if [[ "$available_space" -lt "$required_space" ]]; then
        log_error "Insufficient disk space in $workspace"
        log_error "Need at least 50GB, have $(( available_space / 1024 / 1024 ))GB"
        return 1
    else
        log_success "Sufficient disk space available ($(( available_space / 1024 / 1024 ))GB)"
    fi
    
    # Check memory
    local available_memory=$(free -m | awk 'NR==2{print $7}')
    if [[ "$available_memory" -lt 2048 ]]; then
        log_error "Insufficient memory. Need at least 2GB, have ${available_memory}MB"
        return 1
    elif [[ "$available_memory" -lt 4096 ]]; then
        log_warning "Low memory (${available_memory}MB). Build may be slow. 4GB+ recommended"
    else
        log_success "Sufficient memory available (${available_memory}MB)"
    fi
    
    return 0
}

# Check essential build tools
check_build_tools() {
    log_info "Checking essential build tools..."
    
    local tools=(
        "bash:Shell interpreter"
        "gcc:C compiler"
        "g++:C++ compiler"
        "make:Build automation tool"
        "bison:Parser generator"
        "flex:Lexical analyzer"
        "gawk:AWK interpreter"
        "texinfo:Documentation system"
        "tar:Archive tool"
        "gzip:Compression tool"
        "xz:Compression tool"
        "wget:Download tool"
        "curl:Transfer tool"
        "git:Version control"
        "patch:Patch utility"
        "sed:Stream editor"
        "grep:Pattern matching"
        "binutils:Binary utilities"
        "coreutils:Core utilities"
        "findutils:Find utilities"
        "diffutils:Diff utilities"
        "m4:Macro processor"
    )
    
    local missing=0
    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        if ! check_binary_exists "$tool" "$desc"; then
            missing=$((missing + 1))
        fi
    done
    
    if [[ $missing -gt 0 ]]; then
        log_error "$missing essential tools are missing"
        return 1
    else
        log_success "All essential build tools found"
        return 0
    fi
}

# Check compiler versions
check_compiler_versions() {
    log_info "Checking compiler versions..."
    
    # Check GCC version
    if command -v gcc >/dev/null 2>&1; then
        local gcc_version=$(gcc --version | head -n1)
        log_info "GCC: $gcc_version"
        
        # Check for minimum version (4.9+)
        local gcc_major=$(gcc -dumpversion | cut -d. -f1)
        if [[ "$gcc_major" -lt 4 ]]; then
            log_warning "GCC version is quite old. May cause issues."
        fi
    fi
    
    # Check G++ version
    if command -v g++ >/dev/null 2>&1; then
        local gpp_version=$(g++ --version | head -n1)
        log_info "G++: $gpp_version"
    fi
    
    # Check Make version
    if command -v make >/dev/null 2>&1; then
        local make_version=$(make --version | head -n1)
        log_info "Make: $make_version"
    fi
    
    return 0
}

# Check file system permissions
check_permissions() {
    log_info "Checking file system permissions..."
    
    local workspace="${LFS_WORKSPACE:-$HOME/lfs-workspace}"
    
    # Check if we can create directories
    if mkdir -p "$workspace/test" 2>/dev/null; then
        rm -rf "$workspace/test"
        log_success "Can create directories in workspace"
    else
        log_error "Cannot create directories in $workspace"
        return 1
    fi
    
    # Check if running as root (should not be)
    if [[ $EUID -eq 0 ]]; then
        log_error "Running as root. This is not recommended for LFS builds"
        return 1
    else
        log_success "Not running as root (good)"
    fi
    
    return 0
}

# Check network connectivity
check_network() {
    log_info "Checking network connectivity..."
    
    # Test common package sources
    local test_urls=(
        "https://ftp.gnu.org/gnu/"
        "https://cdn.kernel.org/"
        "https://github.com/"
    )
    
    local failed=0
    for url in "${test_urls[@]}"; do
        if curl -s --head "$url" >/dev/null 2>&1; then
            log_success "Can reach $url"
        else
            log_error "Cannot reach $url"
            failed=$((failed + 1))
        fi
    done
    
    if [[ $failed -gt 0 ]]; then
        log_warning "$failed package sources unreachable. Build may fail."
        return 1
    else
        log_success "All package sources reachable"
        return 0
    fi
}

# Validate environment configuration
check_environment() {
    log_info "Checking environment configuration..."
    
    # Check LFS_WORKSPACE
    local workspace="${LFS_WORKSPACE:-$HOME/lfs-workspace}"
    log_info "LFS_WORKSPACE: $workspace"
    
    # Check BUILD_PROFILE
    local profile="${BUILD_PROFILE:-desktop_gnome}"
    log_info "BUILD_PROFILE: $profile"
    
    # Check PARALLEL_JOBS
    local jobs="${PARALLEL_JOBS:-$(nproc)}"
    log_info "PARALLEL_JOBS: $jobs"
    
    # Validate profile
    case "$profile" in
        desktop_gnome|minimal|server|developer)
            log_success "Valid build profile: $profile"
            ;;
        *)
            log_warning "Unknown build profile: $profile"
            ;;
    esac
    
    # Check if jobs is a number
    if [[ "$jobs" =~ ^[0-9]+$ ]]; then
        log_success "Valid parallel jobs setting: $jobs"
    else
        log_error "Invalid parallel jobs setting: $jobs"
        return 1
    fi
    
    return 0
}

# Check optional components
check_optional_components() {
    log_info "Checking optional components..."
    
    # Check for optional tools that enhance the build
    local optional_tools=(
        "ccache:Compiler cache (speeds up builds)"
        "distcc:Distributed compilation"
        "ninja:Fast build system"
        "python3:Python interpreter"
    )
    
    for tool_info in "${optional_tools[@]}"; do
        local tool="${tool_info%%:*}"
        local desc="${tool_info#*:}"
        if command -v "$tool" >/dev/null 2>&1; then
            log_success "$tool available ($desc)"
        else
            log_info "$tool not available ($desc)"
        fi
    done
    
    return 0
}

# Main validation function
main() {
    log_info "Starting Auto-LFS-Builder validation suite..."
    echo
    
    local errors=0
    
    # Run all validation checks
    check_system_requirements || errors=$((errors + 1))
    echo
    
    check_build_tools || errors=$((errors + 1))
    echo
    
    check_compiler_versions || errors=$((errors + 1))
    echo
    
    check_permissions || errors=$((errors + 1))
    echo
    
    check_network || errors=$((errors + 1))
    echo
    
    check_environment || errors=$((errors + 1))
    echo
    
    check_optional_components || errors=$((errors + 1))
    echo
    
    # Summary
    if [[ $errors -eq 0 ]]; then
        log_success "All validation checks passed!"
        log_info "Your system is ready for LFS building"
        return 0
    else
        log_error "Validation failed with $errors error(s)"
        log_error "Please fix the issues above before building"
        return 1
    fi
}

# Run main function
main "$@"
