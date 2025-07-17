#!/bin/bash

# Auto-LFS-Builder Installation Script
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/c1nderscript/Auto-LFS-Builder.git"
INSTALL_DIR="${HOME}/auto-lfs-builder"
PYTHON_VERSION="3.8"
VENV_NAME="venv"

# Default environment variables
export LFS_WORKSPACE="${HOME}/lfs-workspace"
export BUILD_PROFILE="desktop_gnome"
export GNOME_ENABLED="true"
export NETWORKING_ENABLED="true"
export PARALLEL_JOBS="$(nproc)"
export VALIDATION_MODE="strict"
export VERIFY_PACKAGES="true"
export CHECKSUM_VALIDATION="sha256"

# Arch Linux detection
ARCH_LINUX_DETECTED=false
if [[ -f /etc/arch-release ]]; then
    ARCH_LINUX_DETECTED=true
fi

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}===============================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}===============================================${NC}\n"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        print_info "Please run as a regular user with sudo privileges"
        exit 1
    fi
}

# Check system requirements
check_system_requirements() {
    print_header "Checking System Requirements"
    
    # Check OS
    if [[ "$(uname -s)" != "Linux" ]]; then
        print_error "This script requires Linux"
        exit 1
    fi
    
    # Special message for Arch Linux users
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        print_success "Arch Linux detected - enhanced optimizations will be applied"
    fi
    
    # Check architecture
    local arch=$(uname -m)
    if [[ "$arch" != "x86_64" && "$arch" != "aarch64" ]]; then
        print_warning "Architecture $arch may not be fully supported"
    fi
    
    # Check available disk space (need at least 50GB)
    local available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=52428800  # 50GB in KB
    
    if [[ "$available_space" -lt "$required_space" ]]; then
        print_error "Insufficient disk space. Need at least 50GB available"
        print_info "Available: $(( available_space / 1024 / 1024 ))GB"
        exit 1
    fi
    
    # Check available memory (recommend at least 4GB)
    local available_memory=$(free -m | awk 'NR==2{print $7}')
    if [[ "$available_memory" -lt 4096 ]]; then
        print_warning "Less than 4GB available memory. Build may be slow"
    fi
    
    print_success "System requirements check passed"
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Install system dependencies
install_system_dependencies() {
    print_header "Installing System Dependencies"
    
    local pkg_manager=$(detect_package_manager)
    local packages=""
    
    case $pkg_manager in
        "apt")
            packages="build-essential bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz-utils"
            sudo apt-get update
            sudo apt-get install -y $packages
            ;;
        "dnf"|"yum")
            packages="@development-tools bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz"
            sudo $pkg_manager install -y $packages
            ;;
        "zypper")
            packages="patterns-devel-base-devel_basis bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz"
            sudo zypper install -y $packages
            ;;
        "pacman")
            packages="base-devel bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz"
            sudo pacman -S --noconfirm $packages
            ;;
        *)
            print_error "Unsupported package manager: $pkg_manager"
            print_info "Please install the following packages manually:"
            print_info "build-essential, bison, flex, gawk, texinfo, wget, curl, git, bash, binutils, coreutils, diffutils, findutils, gawk, grep, gzip, m4, make, patch, sed, tar, texinfo, xz-utils"
            exit 1
            ;;
    esac
    
    print_success "System dependencies installed"
}

# Clone or update repository
setup_repository() {
    print_header "Setting up Repository"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        print_info "Directory $INSTALL_DIR already exists"
        if [[ -d "$INSTALL_DIR/.git" ]]; then
            print_info "Updating existing repository"
            cd "$INSTALL_DIR"
            git pull origin main
        else
            print_error "Directory exists but is not a git repository"
            print_info "Please remove $INSTALL_DIR and try again"
            exit 1
        fi
    else
        print_info "Cloning repository to $INSTALL_DIR"
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
    
    print_success "Repository set up"
}

# Setup Arch Linux specific features
setup_arch_linux() {
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        print_header "Setting up Arch Linux Optimizations"
        
        # Run the Arch Linux support script
        if [[ -f "$INSTALL_DIR/scripts/arch-support.sh" ]]; then
            print_info "Running Arch Linux support script..."
            bash "$INSTALL_DIR/scripts/arch-support.sh"
            
            # Make sure arch-specific scripts are executable
            chmod +x "$INSTALL_DIR/scripts/arch-support.sh"
            if [[ -f "$INSTALL_DIR/scripts/arch-validation.sh" ]]; then
                chmod +x "$INSTALL_DIR/scripts/arch-validation.sh"
            fi
            
            print_success "Arch Linux optimizations applied"
        else
            print_warning "Arch Linux support script not found"
        fi
    fi
}

# Create configuration files
create_configuration() {
    print_header "Creating Configuration"
    
    # Create environment configuration file
    cat > "$INSTALL_DIR/lfs-builder.env" << EOF
# Auto-LFS-Builder Environment Configuration
# Source this file to set up your environment

# Core LFS Build Variables
export LFS_WORKSPACE="$LFS_WORKSPACE"
export BUILD_PROFILE="$BUILD_PROFILE"
export PARALLEL_JOBS="$PARALLEL_JOBS"

# Component Control Flags
export GNOME_ENABLED="$GNOME_ENABLED"
export NETWORKING_ENABLED="$NETWORKING_ENABLED"
export ENABLE_MULTIMEDIA="true"
export ENABLE_DEVELOPMENT_TOOLS="true"

# Security and Verification
export VERIFY_PACKAGES="$VERIFY_PACKAGES"
export CHECKSUM_VALIDATION="$CHECKSUM_VALIDATION"
export SECURITY_HARDENING="true"

# Build Optimization
export BUILD_OPTIMIZATION="-O2"
export CCACHE_ENABLED="true"
export CCACHE_SIZE="10G"
export CLEANUP_BUILD_DIRS="true"

# Logging
export LOG_LEVEL="INFO"
export LOG_FORMAT="structured"
export LOG_TIMESTAMPS="true"
EOF
    
    # Create workspace directory
    mkdir -p "$LFS_WORKSPACE"
    
    # Create logs directory
    mkdir -p "$INSTALL_DIR/logs"
    
    print_success "Configuration created"
}

# Create convenience scripts
create_scripts() {
    print_header "Creating Convenience Scripts"
    
    # Create activation script with Arch Linux support
    cat > "$INSTALL_DIR/activate" << 'EOF'
#!/bin/bash
# Activate the Auto-LFS-Builder environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

# Load Arch Linux specific configuration if available
if [[ -f /etc/arch-release && -f "$SCRIPT_DIR/lfs-builder-arch.env" ]]; then
    source "$SCRIPT_DIR/lfs-builder-arch.env"
    echo "Auto-LFS-Builder environment activated (with Arch Linux optimizations)"
else
    echo "Auto-LFS-Builder environment activated"
fi

echo "Workspace: $LFS_WORKSPACE"
echo "Build Profile: $BUILD_PROFILE"
echo "Parallel Jobs: $PARALLEL_JOBS"
echo ""
echo "Available commands:"
echo "  ./lfs-validate    - Run validation suite"
echo "  ./lfs-build       - Start LFS build process"
echo "  ./lfs-test        - Run test suite"
echo "  ./lfs-clean       - Clean build artifacts"

# Arch Linux specific commands
if [[ -f /etc/arch-release ]]; then
    echo ""
    echo "Arch Linux specific commands:"
    echo "  ./scripts/arch-support.sh --validate      - Validate Arch system"
    echo "  ./scripts/arch-support.sh --optimize      - Apply optimizations"
    echo "  ./scripts/arch-support.sh --troubleshoot  - Run diagnostics"
    echo "  ./scripts/arch-validation.sh              - Comprehensive validation"
fi

echo ""
echo "To start building:"
echo "  ./lfs-build"
EOF
    
    # Create validation wrapper with Arch Linux support
    cat > "$INSTALL_DIR/lfs-validate" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

# Load Arch Linux specific configuration if available
if [[ -f /etc/arch-release && -f "$SCRIPT_DIR/lfs-builder-arch.env" ]]; then
    source "$SCRIPT_DIR/lfs-builder-arch.env"
fi

echo "Running validation suite..."

# Run generated validation suite if available
if [[ -f "$SCRIPT_DIR/generated/validation_suite.sh" ]]; then
    bash "$SCRIPT_DIR/generated/validation_suite.sh"
else
    echo "Generated validation suite not found, running basic validation..."
    
    # Basic validation checks
    echo "Checking required tools..."
    required_tools="bash bison flex gawk gcc make tar wget curl git"
    for tool in $required_tools; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✓ $tool found"
        else
            echo "✗ $tool NOT found"
        fi
    done
fi

# Run Arch Linux specific validation if available
if [[ -f /etc/arch-release && -f "$SCRIPT_DIR/scripts/arch-validation.sh" ]]; then
    echo ""
    echo "Running Arch Linux specific validation..."
    bash "$SCRIPT_DIR/scripts/arch-validation.sh"
fi
EOF
    
    # Create build wrapper
    cat > "$INSTALL_DIR/lfs-build" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

# Load Arch Linux specific configuration if available
if [[ -f /etc/arch-release && -f "$SCRIPT_DIR/lfs-builder-arch.env" ]]; then
    source "$SCRIPT_DIR/lfs-builder-arch.env"
    echo "Starting LFS build with Arch Linux optimizations..."
else
    echo "Starting LFS build..."
fi

if [[ -f "$SCRIPT_DIR/lfs-build.sh" ]]; then
    bash "$SCRIPT_DIR/lfs-build.sh" "$@"
else
    echo "Error: lfs-build.sh not found in $SCRIPT_DIR"
    exit 1
fi
EOF
    
    # Create test wrapper
    cat > "$INSTALL_DIR/lfs-test" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

if [[ -d "$SCRIPT_DIR/tests" ]]; then
    bash "$SCRIPT_DIR/tests/run_tests.sh"
else
    echo "Error: tests directory not found"
    exit 1
fi
EOF
    
    # Create cleanup script
    cat > "$INSTALL_DIR/lfs-clean" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

echo "Cleaning build artifacts..."
rm -rf "$LFS_WORKSPACE/lfs"
rm -rf "$LFS_WORKSPACE/sources"
rm -f "$LFS_WORKSPACE/lfs-system.tar.gz"
rm -f "$SCRIPT_DIR/logs/"*.log

# Clean Arch Linux specific artifacts
if [[ -f /etc/arch-release ]]; then
    rm -f "$SCRIPT_DIR/logs/arch-lfs-build.log"
    if command -v ccache &> /dev/null; then
        echo "Clearing ccache..."
        ccache --clear
    fi
fi

echo "Cleanup complete"
EOF
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/activate"
    chmod +x "$INSTALL_DIR/lfs-validate"
    chmod +x "$INSTALL_DIR/lfs-build"
    chmod +x "$INSTALL_DIR/lfs-test"
    chmod +x "$INSTALL_DIR/lfs-clean"
    
    # Make sure main build script is executable
    if [[ -f "$INSTALL_DIR/lfs-build.sh" ]]; then
        chmod +x "$INSTALL_DIR/lfs-build.sh"
    fi
    
    print_success "Convenience scripts created"
}

# Run basic validation
run_validation() {
    print_header "Running Basic Validation"
    
    # Check for essential build tools
    local required_tools="bash bison flex gawk gcc make tar wget curl git"
    local missing_tools=""
    
    for tool in $required_tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools="$missing_tools $tool"
        fi
    done
    
    if [[ -n "$missing_tools" ]]; then
        print_warning "Missing required tools:$missing_tools"
        print_info "Please install these tools before running a build"
    else
        print_success "All required tools found"
    fi
    
    # Run Arch Linux validation if available
    if [[ "$ARCH_LINUX_DETECTED" == "true" && -f "$INSTALL_DIR/scripts/arch-validation.sh" ]]; then
        print_info "Running Arch Linux system validation..."
        if bash "$INSTALL_DIR/scripts/arch-validation.sh"; then
            print_success "Arch Linux validation passed"
        else
            print_warning "Arch Linux validation found issues (see above)"
        fi
    fi
    
    print_success "Basic validation complete"
}

# Create desktop entry (optional)
create_desktop_entry() {
    if command -v xdg-desktop-menu &> /dev/null; then
        print_header "Creating Desktop Entry"
        
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/auto-lfs-builder.desktop" << EOF
[Desktop Entry]
Name=Auto-LFS-Builder
Comment=Automated Linux From Scratch Builder
Exec=gnome-terminal -- bash -c "cd '$INSTALL_DIR' && source activate && bash"
Icon=applications-development
Terminal=true
Type=Application
Categories=Development;System;
EOF
        
        print_success "Desktop entry created"
    fi
}

# Display final instructions
display_instructions() {
    print_header "Installation Complete!"
    
    echo -e "${GREEN}Auto-LFS-Builder has been successfully installed!${NC}\n"
    
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        echo -e "${BLUE}🏗️  Arch Linux optimizations have been applied${NC}\n"
    fi
    
    echo -e "${BLUE}Installation Directory:${NC} $INSTALL_DIR"
    echo -e "${BLUE}Workspace Directory:${NC} $LFS_WORKSPACE"
    echo -e "${BLUE}Build Profile:${NC} $BUILD_PROFILE"
    echo -e "${BLUE}Parallel Jobs:${NC} $PARALLEL_JOBS"
    echo ""
    
    echo -e "${YELLOW}To get started:${NC}"
    echo "1. Navigate to the installation directory:"
    echo "   cd $INSTALL_DIR"
    echo ""
    echo "2. Activate the environment:"
    echo "   source activate"
    echo ""
    echo "3. Run validation (recommended):"
    echo "   ./lfs-validate"
    echo ""
    echo "4. Start building LFS:"
    echo "   ./lfs-build"
    echo ""
    
    echo -e "${YELLOW}Available commands:${NC}"
    echo "  ./lfs-validate  - Run validation suite"
    echo "  ./lfs-build     - Start LFS build process"
    echo "  ./lfs-test      - Run test suite"
    echo "  ./lfs-clean     - Clean build artifacts"
    echo ""
    
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        echo -e "${YELLOW}Arch Linux specific commands:${NC}"
        echo "  ./scripts/arch-support.sh --validate      - Validate Arch system"
        echo "  ./scripts/arch-support.sh --optimize      - Apply optimizations"
        echo "  ./scripts/arch-support.sh --troubleshoot  - Run diagnostics"
        echo "  ./scripts/arch-validation.sh              - Comprehensive validation"
        echo ""
    fi
    
    echo -e "${YELLOW}Configuration:${NC}"
    echo "  Edit $INSTALL_DIR/lfs-builder.env to modify settings"
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        echo "  Edit $INSTALL_DIR/lfs-builder-arch.env for Arch-specific settings"
    fi
    echo "  See SETUP.md for detailed configuration options"
    echo ""
    
    echo -e "${YELLOW}Documentation:${NC}"
    echo "  README.md        - Quick start guide"
    echo "  SETUP.md         - Detailed setup and configuration"
    echo "  AGENTS.md        - Advanced usage"
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        echo "  docs/ARCH-LINUX.md - Arch Linux specific guide"
        echo "  README-ARCH.md     - Arch Linux quick start"
    fi
    echo ""
    
    echo -e "${RED}Important Notes:${NC}"
    echo "• LFS building requires significant time (several hours)"
    echo "• Ensure you have at least 50GB free disk space"
    echo "• The build process will download and compile many packages"
    echo "• Review the configuration in lfs-builder.env before building"
    echo "• Always run validation before starting a build"
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        echo "• Arch Linux optimizations are automatically applied"
        echo "• Consider using ccache and tmpfs for faster builds"
    fi
    echo ""
    
    echo -e "${GREEN}Ready to build Linux From Scratch!${NC}"
    
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        echo -e "${BLUE}🏗️  Arch Linux users: Your system is optimized for LFS building!${NC}"
    fi
}

# Main installation function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            --workspace)
                LFS_WORKSPACE="$2"
                shift 2
                ;;
            --build-profile)
                BUILD_PROFILE="$2"
                shift 2
                ;;
            --parallel-jobs)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --install-dir DIR     Installation directory (default: $INSTALL_DIR)"
                echo "  --workspace DIR       Workspace directory (default: $LFS_WORKSPACE)"
                echo "  --build-profile NAME  Build profile (default: $BUILD_PROFILE)"
                echo "  --parallel-jobs N     Number of parallel jobs (default: $PARALLEL_JOBS)"
                echo "  --help               Show this help message"
                echo ""
                echo "Build profiles:"
                echo "  desktop_gnome        Full GNOME desktop with networking"
                echo "  minimal              Base LFS system only"
                echo "  server               Server configuration with networking, no GUI"
                echo "  developer            Development tools and environment"
                echo ""
                if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
                    echo "Arch Linux detected: Enhanced optimizations will be applied automatically"
                fi
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_info "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    print_header "Auto-LFS-Builder Installation"
    
    if [[ "$ARCH_LINUX_DETECTED" == "true" ]]; then
        print_info "🏗️  Arch Linux detected - Enhanced setup will be applied"
    fi

    print_info "This script will install Auto-LFS-Builder and its dependencies"
    print_info "Installation directory: $INSTALL_DIR"
    print_info "Workspace directory: $LFS_WORKSPACE"
    echo ""
    
    # Run installation steps
    check_root
    check_system_requirements
    install_system_dependencies
    setup_repository
    setup_arch_linux  # New step for Arch Linux
    create_configuration
    create_scripts
    run_validation
    create_desktop_entry
    display_instructions
    
    print_success "Installation completed successfully!"
}

# Run main function
main "$@"
