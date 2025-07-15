#!/bin/bash
# Glibc Build Debug and Recovery Script
# Run this to diagnose and fix the current Glibc build issue

set +e  # Don't exit on errors during debugging

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

echo "==============================================="
echo "         Glibc Build Debug Script"
echo "==============================================="

# 1. Check current environment
LFS_WORKSPACE="${LFS_WORKSPACE:-/mnt/lfs/workspace}"
LFS="${LFS:-$LFS_WORKSPACE/lfs}"

log_info "Checking current environment..."
echo "LFS_WORKSPACE: $LFS_WORKSPACE"
echo "LFS: $LFS"
echo "Current directory: $(pwd)"
echo "Current user: $(whoami)"

# 2. Check if previous build artifacts exist
log_info "Checking build artifacts..."

if [[ -d "$LFS_WORKSPACE/sources" ]]; then
    log_success "Sources directory exists"
    echo "Sources contents:"
    ls -la "$LFS_WORKSPACE/sources" | head -10
else
    log_error "Sources directory not found at $LFS_WORKSPACE/sources"
fi

if [[ -d "$LFS" ]]; then
    log_success "LFS directory exists"
    echo "LFS structure:"
    ls -la "$LFS" 2>/dev/null | head -10
else
    log_error "LFS directory not found at $LFS"
fi

# 3. Check cross-compilation tools
log_info "Checking cross-compilation tools..."
if [[ -d "$LFS/tools" ]]; then
    log_success "Tools directory exists"
    echo "Tools contents:"
    ls -la "$LFS/tools/bin" 2>/dev/null | head -5
    
    # Check if compiler exists
    if [[ -f "$LFS/tools/bin/$(uname -m)-lfs-linux-gnu-gcc" ]]; then
        log_success "Cross-compiler found"
    else
        log_error "Cross-compiler not found"
    fi
else
    log_error "Tools directory not found"
fi

# 4. Check kernel headers
log_info "Checking kernel headers..."
if [[ -d "$LFS/usr/include/linux" ]]; then
    log_success "Kernel headers installed"
    echo "Header files count: $(find "$LFS/usr/include" -name "*.h" | wc -l)"
else
    log_error "Kernel headers not found"
fi

# 5. Check glibc build status
log_info "Checking Glibc build status..."
cd "$LFS_WORKSPACE/sources" 2>/dev/null || {
    log_error "Cannot access sources directory"
    exit 1
}

if [[ -d "glibc-2.39" ]]; then
    log_warning "Glibc source directory still exists - build may have failed"
    cd glibc-2.39
    
    if [[ -d "build" ]]; then
        log_info "Build directory exists - checking logs"
        cd build
        
        if [[ -f "config.log" ]]; then
            echo "Last 20 lines of config.log:"
            tail -20 config.log
        fi
        
        if [[ -f "config.status" ]]; then
            log_success "Configure completed successfully"
        else
            log_error "Configure did not complete"
        fi
        
        # Check for build errors
        if ls *.log 2>/dev/null; then
            echo "Available log files:"
            ls -la *.log
        fi
    fi
else
    log_info "No glibc source directory - may need to extract"
fi

# 6. Check available packages
cd "$LFS_WORKSPACE/sources"
log_info "Checking downloaded packages..."
echo "Available packages:"
ls -la *.tar.* 2>/dev/null | head -10

# 7. Environment variables check
log_info "Checking environment variables..."
echo "LC_ALL: ${LC_ALL:-NOT_SET}"
echo "LFS_TGT: ${LFS_TGT:-NOT_SET}"
echo "PATH: $PATH"
echo "CONFIG_SITE: ${CONFIG_SITE:-NOT_SET}"

# 8. Disk space check
log_info "Checking disk space..."
df -h "$LFS_WORKSPACE"

# 9. Memory check
log_info "Checking available memory..."
free -h

# 10. Process check
log_info "Checking for running build processes..."
if pgrep -f "make\|gcc\|configure" > /dev/null; then
    log_warning "Build processes still running:"
    pgrep -f "make\|gcc\|configure" -l
else
    log_info "No build processes running"
fi

echo
echo "==============================================="
echo "              DIAGNOSIS COMPLETE"
echo "==============================================="
echo

# 11. Provide recovery suggestions
log_info "Recovery suggestions:"

echo "1. Clean up any failed glibc build:"
echo "   cd $LFS_WORKSPACE/sources"
echo "   rm -rf glibc-2.39"
echo

echo "2. Check that all prerequisites are met:"
echo "   - Cross-compilation tools in $LFS/tools"
echo "   - Kernel headers in $LFS/usr/include"
echo "   - Sufficient disk space (>50GB)"
echo

echo "3. Retry glibc build with debug output:"
echo "   export VERBOSE=true"
echo "   export LFS=$LFS"
echo "   export LFS_TGT=\$(uname -m)-lfs-linux-gnu"
echo "   export CONFIG_SITE=$LFS/usr/share/config.site"
echo "   # Then run the build_glibc function"
echo

echo "4. Manual glibc build (if needed):"
echo "   cd $LFS_WORKSPACE/sources"
echo "   tar -xf glibc-2.39.tar.xz"
echo "   cd glibc-2.39"
echo "   mkdir build && cd build"
echo "   echo 'rootsbindir=/usr/sbin' > configparms"
echo "   ../configure --prefix=/usr --host=\$LFS_TGT --build=\$(../scripts/config.guess) --enable-kernel=4.19 --with-headers=\$LFS/usr/include --disable-nscd libc_cv_slibdir=/usr/lib libc_cv_rtlddir=/usr/lib"
echo

# 12. Check if we can fix the immediate issue
if [[ -d "$LFS_WORKSPACE/sources/glibc-2.39" ]]; then
    echo "Would you like to clean up the failed glibc build? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy] ]]; then
        log_info "Cleaning up failed glibc build..."
        rm -rf "$LFS_WORKSPACE/sources/glibc-2.39"
        log_success "Cleanup complete"
    fi
fi

echo
log_info "Debug script complete. Check the output above for issues."
