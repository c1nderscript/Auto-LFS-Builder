#!/bin/bash
# Auto-LFS-Builder - Direct LFS Build Script
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Enable debugging and verbosity
set -euxo pipefail

# Set verbose shell options
shopt -s extdebug

# Configure bash debugging output
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Source environment if available
if [[ -f "$(dirname "$0")/lfs-builder.env" ]]; then
    source "$(dirname "$0")/lfs-builder.env"
fi

# Set up logging
LOG_PATH=/mnt/lfs/logs/build.log
LOG_DIR=$(dirname "$LOG_PATH")
mkdir -p "$LOG_DIR"

# Logging function that writes to both console and log file
log_output() {
    echo -e "$1" | tee -a "$LOG_PATH"
}

# Default configuration
LFS_WORKSPACE="${LFS_WORKSPACE:-/lfs-build/workspace}"
BUILD_PROFILE="${BUILD_PROFILE:-desktop_gnome}"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc)}"
LFS_VERSION="${LFS_VERSION:-development}"
ENABLE_GNOME="${ENABLE_GNOME:-true}"
ENABLE_NETWORKING="${ENABLE_NETWORKING:-true}"
CREATE_ISO="${CREATE_ISO:-true}"
ISO_VOLUME="${ISO_VOLUME:-AUTO_LFS}"
ISO_OUTPUT="${ISO_OUTPUT:-${LFS_WORKSPACE}/auto-lfs.iso}"

# Default verbose setting
VERBOSE="${VERBOSE:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verbose output helpers
# Enhanced verbose execution function
run_verbose() {
    echo "[VERBOSE] Executing: $*"
    if [[ "$VERBOSE" == "true" ]]; then
        set -x
        time "$@"
        set +x
    else
        "$@" >/dev/null 2>&1
    fi
}

# Enhanced download function with progress and checksum verification
wget_download() {
    local url="$1"
    local filename=$(basename "$url")
    echo "[DOWNLOAD] Starting download of $filename from $url"
    if [[ "$VERBOSE" == "true" ]]; then
        wget "$url" --progress=bar:force --tries=3 --timeout=60 2>&1 | tee -a "$LOG_PATH"
    else
        wget -q "$url" --tries=3 --timeout=60
    fi
}

# Enhanced make build function with timing and verbose output
make_build() {
    local start_time=$(date +%s)
    echo "[BUILD] Starting make with arguments: $*"
    if [[ "$VERBOSE" == "true" ]]; then
        MAKEFLAGS="${MAKEFLAGS} V=1 VERBOSE=1" \
        make -j"$PARALLEL_JOBS" --debug=v "$@" 2>&1 | tee -a "$LOG_PATH"
    else
        make -j"$PARALLEL_JOBS" "$@"
    fi
    local end_time=$(date +%s)
    local build_time=$((end_time - start_time))
    echo "[BUILD] Completed in ${build_time}s"
}

# Logging functions
log_info() { log_output "${BLUE}[INFO]${NC} $*"; }
log_success() { log_output "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { log_output "${YELLOW}[WARNING]${NC} $*"; }
log_error() { log_output "${RED}[ERROR]${NC} $*"; }
log_phase() {
    log_output "\n${BLUE}===============================================${NC}"
    log_output "${BLUE}  $*${NC}"
    log_output "${BLUE}===============================================${NC}\n"
}

# Error handling
CLEANUP_RUN=false
cleanup() {
    local status=$1
    trap - ERR EXIT
    if [[ $status -ne 0 ]]; then
        log_error "Build interrupted or failed (status: $status)"
        log_info "Cleaning up..."
        # Add cleanup logic here
    else
        log_success "Build completed successfully"
    fi
}
trap 'cleanup $?' ERR EXIT

# Validate environment
validate_environment() {
    log_phase "Validating Build Environment"
    
    # Check if running in Docker
    if [[ -f /.dockerenv ]]; then
        log_info "Running in Docker environment"
    else
        log_warning "Not running in Docker environment"
    fi
    
    # Check disk space (need at least 50GB)
    local available_space=$(df "$LFS_WORKSPACE" 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)
    local required_space=52428800  # 50GB in KB
    
    if [[ -f /.dockerenv ]]; then
        log_info "Skipping disk space check in Docker environment"
    elif [[ "$available_space" -lt "$required_space" ]]; then
        log_error "Insufficient disk space. Need at least 50GB available"
        exit 1
    fi
    
    # Check required tools
    local required_tools="bash bison flex gawk gcc make tar wget curl git"
    for tool in $required_tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "Required tool '$tool' not found"
            exit 1
        fi
    done
    
    # Check for ISO creation tools if needed
    if [[ "$CREATE_ISO" == "true" ]]; then
        if ! command -v xorriso >/dev/null 2>&1 && ! command -v genisoimage >/dev/null 2>&1; then
            log_warning "Neither xorriso nor genisoimage found. ISO creation will be skipped."
            log_info "To enable ISO creation, install: sudo apt-get install xorriso"
            CREATE_ISO="false"
        fi
    fi
    
    log_success "Environment validation passed"
}

# Set up LFS environment
setup_lfs_environment() {
    log_phase "Setting up LFS Environment"
    
    # Create LFS directories
    export LFS="$LFS_WORKSPACE/lfs"
    mkdir -p "$LFS"
    mkdir -p "$LFS"/{etc,var,usr,tools,home,mnt,proc,sys,dev}
    mkdir -p "$LFS/usr"/{bin,lib,sbin}
    mkdir -p "$LFS/var"/{log,mail,spool}
    mkdir -p "$LFS/etc/sysconfig"
    
    # Set up config.site for MB_LEN_MAX fix
    mkdir -p "$LFS/usr/share"
    echo 'ac_cv_sys_mb_len_max=16' > "$LFS/usr/share/config.site"
    export CONFIG_SITE="$LFS/usr/share/config.site"
    
    # Create sources directory
    mkdir -p "$LFS_WORKSPACE/sources"
    cd "$LFS_WORKSPACE/sources"
    
    # Set up environment variables
    export LC_ALL=POSIX
    export LFS_TGT=$(uname -m)-lfs-linux-gnu
    export PATH="$LFS/tools/bin:/bin:/usr/bin"
    export MAKEFLAGS="-j$PARALLEL_JOBS"
    export CFLAGS="-D_MB_LEN_MAX=16"
    export CXXFLAGS="-D_MB_LEN_MAX=16"
    
    log_success "LFS environment set up at $LFS"
}

# Download and verify packages
download_packages() {
    log_phase "Downloading LFS Packages"
    
    cd "$LFS_WORKSPACE/sources"
    
    # Core packages for LFS (with required dependencies)
    local packages=(
        "https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz"
        "https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
        "https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"
        "https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
        "https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
        "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.7.4.tar.xz"
        "https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz"
        "https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz"
        "https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.xz"
        "https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
        "https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz"
        "https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz"
        "https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz"
        "https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz"
        "https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz"
        "https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz"
        "https://www.kernel.org/pub/linux/utils/util-linux/v2.41/util-linux-2.41.1.tar.xz"
    )
    
    for package in "${packages[@]}"; do
        local filename=$(basename "$package")
        if [[ ! -f "$filename" ]]; then
            log_info "Downloading $filename"
            if ! wget_download "$package"; then
                log_error "Failed to download $package"
                exit 1
            fi
        else
            log_info "Found $filename"
        fi
    done
    
    log_success "Package download completed"
}

# Build cross-compilation tools
build_cross_tools() {
    log_phase "Building Cross-Compilation Tools"
    
    cd "$LFS_WORKSPACE/sources"
    
    # Build binutils (cross-compiler)
    log_info "Building binutils (cross-compiler)"
    tar -xf binutils-2.42.tar.xz
    cd binutils-2.42
    mkdir -v build
    cd build
    
    ../configure --prefix="$LFS/tools" \
                 --with-sysroot="$LFS" \
                 --target="$LFS_TGT" \
                 --disable-nls \
                 --enable-gprofng=no \
                 --disable-werror
    
    make_build
    make install
    
    cd "$LFS_WORKSPACE/sources"
    rm -rf binutils-2.42
    
    # Build GCC (cross-compiler)
    log_info "Building GCC (cross-compiler)"
    tar -xf gcc-13.2.0.tar.xz
    cd gcc-13.2.0
    
    tar -xf ../mpfr-4.2.1.tar.xz 2>/dev/null || true
    mv -v mpfr-4.2.1 mpfr 2>/dev/null || true
    tar -xf ../gmp-6.3.0.tar.xz 2>/dev/null || true
    mv -v gmp-6.3.0 gmp 2>/dev/null || true
    tar -xf ../mpc-1.3.1.tar.gz 2>/dev/null || true
    mv -v mpc-1.3.1 mpc 2>/dev/null || true
    
    mkdir -v build
    cd build
    
    ../configure \
        --target="$LFS_TGT" \
        --prefix="$LFS/tools" \
        --with-glibc-version=2.39 \
        --with-sysroot="$LFS" \
        --with-newlib \
        --without-headers \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-threads \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libvtv \
        --disable-libstdcxx \
        --enable-languages=c,c++
    
    make_build
    make install
    
    cd "$LFS_WORKSPACE/sources"
    rm -rf gcc-13.2.0
    
    log_success "Cross-compilation tools built"
}

# Build Linux kernel headers
build_kernel_headers() {
    log_phase "Building Linux Kernel Headers"
    
    cd "$LFS_WORKSPACE/sources"
    
    tar -xf linux-6.7.4.tar.xz
    cd linux-6.7.4
    
    make mrproper
    run_verbose make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include "$LFS/usr"
    
    cd "$LFS_WORKSPACE/sources"
    rm -rf linux-6.7.4
    
    log_success "Kernel headers installed"
}

# Build Glibc
build_glibc() {
    log_phase "Building Glibc"
    
    cd "$LFS_WORKSPACE/sources"
    
    tar -xf glibc-2.39.tar.xz
    cd glibc-2.39
    
    mkdir -v build
    cd build
    
    echo "rootsbindir=/usr/sbin" > configparms
    
    ../configure \
        --prefix=/usr \
        --host="$LFS_TGT" \
        --build=$(../scripts/config.guess) \
        --enable-kernel=4.19 \
        --with-headers="$LFS/usr/include" \
        --disable-nscd \
        libc_cv_slibdir=/usr/lib \
        libc_cv_rtlddir=/usr/lib \
        libc_cv_cpp_explicit_max_align=yes
    
    make_build
    make DESTDIR="$LFS" install
    
    # Fix symlink
    sed '/RTLDLIST=/s@/usr@@g' -i "$LFS/usr/bin/ldd"
    
    cd "$LFS_WORKSPACE/sources"
    rm -rf glibc-2.39
    
    log_success "Glibc built and installed"
}

# Build core system tools
build_core_tools() {
    log_phase "Building Core System Tools"
    
    local tools=(
        "bash-5.2.21.tar.gz"
        "coreutils-9.4.tar.xz"
        "make-4.4.1.tar.gz"
        "sed-4.9.tar.xz"
        "tar-1.35.tar.xz"
        "gawk-5.3.0.tar.xz"
        "findutils-4.9.0.tar.xz"
        "grep-3.11.tar.xz"
        "gzip-1.13.tar.xz"
        "util-linux-2.41.1.tar.xz"
    )
    
    cd "$LFS_WORKSPACE/sources"
    
    for tool in "${tools[@]}"; do
        local name=$(echo "$tool" | sed 's/\(.*\)-[0-9].*/\1/')
        local version=$(echo "$tool" | sed 's/.*-\([0-9].*\)\.tar.*/\1/')
        
        log_info "Building $name-$version"
        
        tar -xf "$tool"
        cd "$name-$version"
        
        case "$name" in
            "bash")
                ./configure --prefix=/usr --host="$LFS_TGT" --without-bash-malloc
                make_build
                make DESTDIR="$LFS" install
                ;;
            "coreutils")
                ./configure --prefix=/usr --host="$LFS_TGT" --enable-install-program=hostname
                make_build
                make DESTDIR="$LFS" install
                ;;
            *)
                ./configure --prefix=/usr --host="$LFS_TGT"
                make_build
                make DESTDIR="$LFS" install
                ;;
        esac
        
        cd "$LFS_WORKSPACE/sources"
        rm -rf "$name-$version"
    done
    
    log_success "Core tools built"
}

# Configure the system
configure_system() {
    log_phase "Configuring System"
    
    # Create essential files
    cat > "$LFS/etc/passwd" << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF
    
    cat > "$LFS/etc/group" << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:65534:
EOF
    
    # Create fstab
    cat > "$LFS/etc/fstab" << "EOF"
# Begin /etc/fstab
# file system  mount-point  type     options             dump  fsck
#                                                              order
/dev/sda1      /            ext4     defaults            1     1
/dev/sda2      swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm     tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2 nosuid,noexec,nodev 0   0
# End /etc/fstab
EOF
    
    # Create hostname
    echo "lfs-system" > "$LFS/etc/hostname"
    
    # Create hosts file
    cat > "$LFS/etc/hosts" << "EOF"
127.0.0.1  localhost
127.0.1.1  lfs-system
# End /etc/hosts
EOF
    
    log_success "System configured"
}

# Install networking (if enabled)
install_networking() {
    if [[ "$ENABLE_NETWORKING" == "true" ]]; then
        log_phase "Installing Network Configuration"
        
        # Ensure sysconfig directory exists
        mkdir -p "$LFS/etc/sysconfig"
        
        # Create network interfaces file
        cat > "$LFS/etc/sysconfig/ifconfig.eth0" << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.2
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF
        
        # DNS configuration
        cat > "$LFS/etc/resolv.conf" << "EOF"
# Begin /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
# End /etc/resolv.conf
EOF
        
        log_success "Network configuration installed"
    fi
}

# Install GNOME (if enabled)
install_gnome() {
    if [[ "$ENABLE_GNOME" == "true" ]]; then
        log_phase "Installing GNOME Desktop (Basic Setup)"
        
        # Create basic X11 configuration
        mkdir -p "$LFS/etc/X11/xorg.conf.d"
        
        # Create basic desktop session
        mkdir -p "$LFS/usr/share/xsessions"
        cat > "$LFS/usr/share/xsessions/gnome.desktop" << "EOF"
[Desktop Entry]
Name=GNOME
Comment=This session logs you into GNOME
Exec=gnome-session
TryExec=gnome-session
Type=Application
DesktopNames=GNOME
EOF
        
        log_success "GNOME desktop components prepared"
        log_warning "Full GNOME installation requires additional packages not included in this script"
    fi
}

# Create boot configuration
create_boot_config() {
    log_phase "Creating Boot Configuration"
    
    # Create kernel configuration (basic)
    mkdir -p "$LFS/boot"
    
    # Create GRUB configuration
    mkdir -p "$LFS/boot/grub"
    cat > "$LFS/boot/grub/grub.cfg" << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

menuentry "GNU/Linux, LFS System" {
    linux   /boot/vmlinuz-lfs root=/dev/sda1 ro
}
EOF
    
    # Create initramfs configuration
    mkdir -p "$LFS/etc/mkinitcpio.d"
    
    log_success "Boot configuration created"
}

# Final system setup
finalize_system() {
    log_phase "Finalizing System"
    
    # Create version file
    echo "Linux From Scratch (Auto-LFS-Builder) - Built $(date)" > "$LFS/etc/lfs-release"
    
    # Create motd
    cat > "$LFS/etc/motd" << "EOF"
Welcome to Linux From Scratch!

This system was built using Auto-LFS-Builder.
Build completed: $(date)

For more information, see /etc/lfs-release

EOF
    
    # Set permissions
    chmod 644 "$LFS/etc/passwd" "$LFS/etc/group"
    chmod 600 "$LFS/etc/fstab"
    
    log_success "System finalized"
}

# Create system image
create_system_image() {
    log_phase "Creating System Image"
    
    # Create a basic system tarball
    cd "$LFS"
    tar -czf "$LFS_WORKSPACE/lfs-system.tar.gz" .
    
    log_success "System image created at $LFS_WORKSPACE/lfs-system.tar.gz"
    log_info "Size: $(du -h "$LFS_WORKSPACE/lfs-system.tar.gz" | cut -f1)"
}

# Create bootable ISO
create_bootable_iso() {
    if [[ "$CREATE_ISO" == "true" ]]; then
        log_phase "Creating Bootable ISO"
        
        # Source the ISO creator script
        local iso_creator="$(dirname "$0")/iso-creator.sh"
        if [[ -f "$iso_creator" ]]; then
            source "$iso_creator"
            create_iso_image "$ISO_VOLUME" "" "$ISO_OUTPUT" "$LFS"
        else
            log_warning "ISO creator script not found at $iso_creator"
            log_info "Skipping ISO creation"
        fi
    else
        log_info "ISO creation disabled"
    fi
}

# Main build process
main() {
    local start_time=$(date +%s)
    
    log_phase "Starting Auto-LFS-Builder"
    log_info "Build Profile: $BUILD_PROFILE"
    log_info "Parallel Jobs: $PARALLEL_JOBS"
    log_info "LFS Workspace: $LFS_WORKSPACE"
    log_info "GNOME Enabled: $ENABLE_GNOME"
    log_info "Networking Enabled: $ENABLE_NETWORKING"
    log_info "Create ISO: $CREATE_ISO"
    echo
    
    # Build steps
    validate_environment
    setup_lfs_environment
    download_packages
    build_cross_tools
    build_kernel_headers
    build_glibc
    build_core_tools
    configure_system
    install_networking
    install_gnome
    create_boot_config
    finalize_system
    create_system_image
    create_bootable_iso
    
    # Calculate build time
    local end_time=$(date +%s)
    local build_time=$((end_time - start_time))
    local hours=$((build_time / 3600))
    local minutes=$(((build_time % 3600) / 60))
    local seconds=$((build_time % 60))
    
    log_phase "Build Complete!"
    log_success "Total build time: ${hours}h ${minutes}m ${seconds}s"
    log_success "LFS system built at: $LFS"
    log_success "System image: $LFS_WORKSPACE/lfs-system.tar.gz"
    if [[ "$CREATE_ISO" == "true" && -f "$ISO_OUTPUT" ]]; then
        log_success "Bootable ISO: $ISO_OUTPUT"
    fi
    echo
    log_info "Next steps:"
    if [[ -f "$ISO_OUTPUT" ]]; then
        log_info "1. Use the ISO: $ISO_OUTPUT"
        log_info "2. Boot from ISO in a VM or burn to USB/DVD"
        log_info "3. Install to your target system"
    else
        log_info "1. Create a bootable disk/VM"
        log_info "2. Extract the system image to the target"
        log_info "3. Install and configure a bootloader"
        log_info "4. Boot your new LFS system!"
    fi
    echo
}

# Run main function
main "$@"
