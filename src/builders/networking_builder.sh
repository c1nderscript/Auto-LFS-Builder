#!/bin/bash
# Networking Builder: Configure network stack
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

install_network_stack() {
    # Install NetworkManager as described in docs/blfs-git/networking/netutils/networkmanager.xml
    log_info "Installing NetworkManager" || true
    download_package "NetworkManager" "https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/releases/&NetworkManager-version;/downloads/NetworkManager-&NetworkManager-version;.tar.xz" "01f0a90e1a0dcb88e7140ccbefb4a749" || handle_error "download NetworkManager"
    build_package "NetworkManager" "./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make && make install" || handle_error "build NetworkManager"

    log_info "Installing wireless tools" || true
    download_package "wireless-tools" "https://example.com/wireless-tools.tar.gz" "dummy" || handle_error "download wireless tools"
    build_package "wireless-tools" "make && make install" || handle_error "build wireless tools"

    log_info "Configuring firewall" || true
    systemctl enable nftables.service || handle_error "enable firewall"
}

configure_network_services() {
    # Enable common network services
    log_info "Configuring SSH service" || true
    systemctl enable sshd.service || handle_error "enable sshd"

    log_info "Configuring NTP" || true
    systemctl enable systemd-timesyncd.service || handle_error "enable NTP"

    log_info "Configuring DHCP client" || true
    systemctl enable dhcpcd.service || handle_error "enable DHCP"
}

main() {
    log_info "Starting networking build process"
    install_network_stack
    configure_network_services
    log_success "Networking build completed successfully"
}

main "$@"
