#!/bin/bash
# GNOME Builder: Install GNOME desktop environment
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

install_graphics_stack() {
    # Build Mesa and graphics drivers based on docs/blfs-git
    log_info "Building Mesa 3D" || true
    download_package "mesa" "https://mesa.freedesktop.org/archive/mesa-24.0.1.tar.xz" "dummy" || handle_error "download mesa"
    build_package "mesa" "meson setup build --prefix=/usr && ninja -C build && ninja -C build install" || handle_error "build mesa"

    log_info "Installing Wayland" || true
    download_package "wayland" "https://wayland.freedesktop.org/releases/wayland-1.22.0.tar.xz" "dummy" || handle_error "download wayland"
    build_package "wayland" "./configure --prefix=/usr && make && make install" || handle_error "build wayland"
}

install_gnome_core() {
    # Install GTK and GNOME Shell referencing docs/glfs/gnome.ent
    log_info "Installing GTK4" || true
    download_package "gtk4" "https://download.gnome.org/sources/gtk/4.14/gtk-4.14.2.tar.xz" "dummy" || handle_error "download gtk4"
    build_package "gtk4" "meson setup build --prefix=/usr && ninja -C build && ninja -C build install" || handle_error "build gtk4"

    log_info "Installing GNOME Shell" || true
    download_package "gnome-shell" "https://download.gnome.org/sources/gnome-shell/45/gnome-shell-45.4.tar.xz" "dummy" || handle_error "download gnome-shell"
    build_package "gnome-shell" "meson setup build --prefix=/usr && ninja -C build && ninja -C build install" || handle_error "build gnome-shell"

    log_info "Installing GDM display manager" || true
    download_package "gdm" "https://download.gnome.org/sources/gdm/45/gdm-45.0.tar.xz" "dummy" || handle_error "download gdm"
    build_package "gdm" "meson setup build --prefix=/usr && ninja -C build && ninja -C build install" || handle_error "build gdm"
}

configure_desktop_environment() {
    # Configure GNOME session and themes
    log_info "Setting up GNOME session" || true
    systemctl enable gdm.service || handle_error "enable gdm"

    log_info "Applying default themes" || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita' || handle_error "apply theme"
}

main() {
    log_info "Starting GNOME build process"
    install_graphics_stack
    install_gnome_core
    configure_desktop_environment
    log_success "GNOME build completed successfully"
}

main "$@"
