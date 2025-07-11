#!/bin/bash
# BLFS Builder: Install additional BLFS packages
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

install_blfs_packages() {
    # Install additional BLFS packages such as fonts and utilities
    log_info "Installing fonts" || true
    download_package "dejavu-fonts" "https://downloads.sourceforge.net/project/dejavu/dejavu/2.37/dejavu-fonts-ttf-2.37.tar.bz2" "dummy" || handle_error "download fonts"
    build_package "dejavu-fonts" "install -v -d -m755 /usr/share/fonts/dejavu && cp -v *.ttf /usr/share/fonts/dejavu" || handle_error "install fonts"

    log_info "Installing network utilities" || true
    download_package "wget" "https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz" "dummy" || handle_error "download wget"
    build_package "wget" "./configure --prefix=/usr && make && make install" || handle_error "build wget"
}

configure_blfs_services() {
    # Enable additional services
    log_info "Enabling Avahi daemon" || true
    systemctl enable avahi-daemon.service || handle_error "enable avahi"
}

main() {
    log_info "Starting BLFS build process"
    install_blfs_packages
    configure_blfs_services
    log_success "BLFS build completed successfully"
}

main "$@"
