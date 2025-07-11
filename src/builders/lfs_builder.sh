#!/bin/bash
# LFS Builder: Core LFS build automation
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

build_toolchain() {
    # Construct the cross toolchain following docs/lfs-git/chapter05/binutils-pass1.xml
    log_info "Building cross Binutils" || true
    mkdir -pv "$LFS/sources/binutils-build" || handle_error "create binutils build dir"
    pushd "$LFS/sources/binutils-build" > /dev/null || handle_error "enter binutils build dir"
    ../binutils-*/configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-new-dtags || handle_error "configure binutils"
    make $LFS_MAKEFLAGS || handle_error "compile binutils"
    make install || handle_error "install binutils"
    popd > /dev/null || handle_error "leave binutils build dir"
    log_info "Cross Binutils build finished" || true
}

build_temporary_system() {
    # Enter the chroot environment as described in docs/lfs-git/chapter07/chroot.xml
    log_info "Entering chroot for temporary system" || true
    chroot "$LFS" /usr/bin/env -i \
        HOME=/root TERM="$TERM" \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/usr/bin:/usr/sbin \
        MAKEFLAGS="$LFS_MAKEFLAGS" \
        TESTSUITEFLAGS="$LFS_MAKEFLAGS" \
        /bin/bash --login -c "echo 'Building temporary tools inside chroot'" || handle_error "enter chroot"
}

build_final_system() {
    # Build the final system including the kernel
    log_info "Building Linux kernel" || true
    chroot "$LFS" /bin/bash -c "cd /sources/linux-* && make menuconfig && make -j\$(nproc) && make modules_install && cp -v arch/x86/boot/bzImage /boot/vmlinuz-lfs" || handle_error "kernel build"
    log_info "Kernel build complete" || true
}

main() {
    log_info "Starting LFS build process"
    build_toolchain
    build_temporary_system
    build_final_system
    log_success "LFS build completed successfully"
}

main "$@"
