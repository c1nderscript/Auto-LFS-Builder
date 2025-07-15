#!/bin/bash

# Auto-LFS-Builder - Arch Linux Quick Setup Script
# This script provides a one-command setup for Arch Linux users

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}[ARCH-SETUP]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_header() {
    echo -e "\n${BLUE}===============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}===============================================${NC}\n"
}

# Check if running on Arch Linux
check_arch_linux() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This script is designed for Arch Linux only!"
        print_info "For other distributions, use: https://github.com/c1nderscript/Auto-LFS-Builder"
        exit 1
    fi
    
    print_success "Arch Linux detected"
}

# Main setup function
main() {
    print_header "Auto-LFS-Builder - Arch Linux Quick Setup"
    
    check_arch_linux
    
    print_info "This script will:"
    print_info "1. Install required dependencies"
    print_info "2. Clone the Auto-LFS-Builder repository"
    print_info "3. Apply Arch Linux optimizations"
    print_info "4. Set up the build environment"
    echo
    
    read -p "Continue with setup? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled"
        exit 0
    fi
    
    # Install basic dependencies
    print_info "Installing basic dependencies..."
    sudo pacman -S --needed --noconfirm git curl wget
    
    # Clone repository
    print_info "Cloning Auto-LFS-Builder repository..."
    local install_dir="${HOME}/auto-lfs-builder"
    
    if [[ -d "$install_dir" ]]; then
        print_info "Directory exists, updating..."
        cd "$install_dir"
        git pull origin main
    else
        git clone https://github.com/c1nderscript/Auto-LFS-Builder.git "$install_dir"
        cd "$install_dir"
    fi
    
    # Run Arch Linux setup
    print_info "Running Arch Linux optimization setup..."
    if [[ -f "scripts/arch-support.sh" ]]; then
        bash scripts/arch-support.sh
    else
        print_warning "Arch support script not found, running standard setup..."
    fi
    
    # Run standard installation
    print_info "Running standard installation..."
    bash install.sh
    
    print_header "Setup Complete!"
    
    echo -e "${GREEN}🎉 Auto-LFS-Builder is now ready for Arch Linux!${NC}"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Navigate to the installation directory:"
    echo "   cd ~/auto-lfs-builder"
    echo
    echo "2. Activate the environment:"
    echo "   source activate"
    echo
    echo "3. Run validation:"
    echo "   ./lfs-validate"
    echo "   ./scripts/arch-validation.sh"
    echo
    echo "4. Start building:"
    echo "   ./lfs-build"
    echo
    echo -e "${BLUE}📖 Documentation:${NC}"
    echo "   docs/ARCH-LINUX.md - Complete Arch Linux guide"
    echo "   README-ARCH.md     - Quick start guide"
    echo
    echo -e "${GREEN}Happy building! 🏗️${NC}"
}

main "$@"
