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
export ENABLE_GNOME="true"
export ENABLE_NETWORKING="true"
export PARALLEL_JOBS="$(nproc)"
export PARSING_LOG_LEVEL="INFO"
export VALIDATION_MODE="strict"
export VERIFY_PACKAGES="true"
export CHECKSUM_VALIDATION="sha256"

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
            packages="build-essential bison flex gawk texinfo wget curl git python3 python3-pip python3-venv libxml2-utils pandoc bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz-utils"
            sudo apt-get update
            sudo apt-get install -y $packages
            ;;
        "dnf"|"yum")
            packages="@development-tools bison flex gawk texinfo wget curl git python3 python3-pip libxml2 pandoc bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz"
            sudo $pkg_manager install -y $packages
            ;;
        "zypper")
            packages="patterns-devel-base-devel_basis bison flex gawk texinfo wget curl git python3 python3-pip libxml2-tools pandoc bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz"
            sudo zypper install -y $packages
            ;;
        "pacman")
            packages="base-devel bison flex gawk texinfo wget curl git python python-pip libxml2 pandoc bash binutils coreutils diffutils findutils gawk grep gzip m4 make patch sed tar texinfo xz"
            sudo pacman -S --noconfirm $packages
            ;;
        *)
            print_error "Unsupported package manager: $pkg_manager"
            print_info "Please install the following packages manually:"
            print_info "build-essential, bison, flex, gawk, texinfo, wget, curl, git, python3, python3-pip, python3-venv, libxml2-utils, pandoc"
            exit 1
            ;;
    esac
    
    print_success "System dependencies installed"
}

# Install Python dependencies
install_python_dependencies() {
    print_header "Setting up Python Environment"
    
    # Check Python version
    if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
        print_error "Python 3.8 or higher is required"
        exit 1
    fi
    
    # Create virtual environment
    python3 -m venv "$INSTALL_DIR/$VENV_NAME"
    
    # Activate virtual environment
    source "$INSTALL_DIR/$VENV_NAME/bin/activate"
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install requirements
    pip install -r "$INSTALL_DIR/requirements.txt"
    
    print_success "Python environment set up"
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
export ENABLE_GNOME="$ENABLE_GNOME"
export ENABLE_NETWORKING="$ENABLE_NETWORKING"
export ENABLE_MULTIMEDIA="true"
export ENABLE_DEVELOPMENT_TOOLS="true"

# Documentation Processing
export DOCS_ROOT="$INSTALL_DIR/docs"
export GENERATED_DIR="$INSTALL_DIR/generated"
export PARSING_LOG_LEVEL="$PARSING_LOG_LEVEL"
export VALIDATION_MODE="$VALIDATION_MODE"

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

# Python virtual environment
export VIRTUAL_ENV="$INSTALL_DIR/$VENV_NAME"
export PATH="$INSTALL_DIR/$VENV_NAME/bin:\$PATH"
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
    
    # Create activation script
    cat > "$INSTALL_DIR/activate" << 'EOF'
#!/bin/bash
# Activate the Auto-LFS-Builder environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

echo "Auto-LFS-Builder environment activated"
echo "Workspace: $LFS_WORKSPACE"
echo "Build Profile: $BUILD_PROFILE"
echo "Parallel Jobs: $PARALLEL_JOBS"
echo ""
echo "Available commands:"
echo "  lfs-validate    - Run validation suite"
echo "  lfs-build       - Start LFS build process"
echo "  lfs-test        - Run test suite"
echo "  lfs-clean       - Clean build artifacts"
echo ""
echo "To run a build:"
echo "  bash generated/complete_build.sh"
EOF
    
    # Create validation wrapper
    cat > "$INSTALL_DIR/lfs-validate" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

if [[ -f "$GENERATED_DIR/validation_suite.sh" ]]; then
    bash "$GENERATED_DIR/validation_suite.sh"
else
    echo "Error: validation_suite.sh not found in $GENERATED_DIR"
    echo "Please run the documentation parser first"
    exit 1
fi
EOF
    
    # Create build wrapper
    cat > "$INSTALL_DIR/lfs-build" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lfs-builder.env"

if [[ -f "$GENERATED_DIR/complete_build.sh" ]]; then
    bash "$GENERATED_DIR/complete_build.sh"
else
    echo "Error: complete_build.sh not found in $GENERATED_DIR"
    echo "Please run the documentation parser first"
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
rm -rf "$LFS_WORKSPACE/build"
rm -rf "$LFS_WORKSPACE/sources"
rm -f "$SCRIPT_DIR/logs/"*.log
echo "Cleanup complete"
EOF
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/activate"
    chmod +x "$INSTALL_DIR/lfs-validate"
    chmod +x "$INSTALL_DIR/lfs-build"
    chmod +x "$INSTALL_DIR/lfs-test"
    chmod +x "$INSTALL_DIR/lfs-clean"
    
    print_success "Convenience scripts created"
}

# Run validation
run_validation() {
    print_header "Running Validation Suite"
    
    # Source environment
    source "$INSTALL_DIR/lfs-builder.env"
    
    # Run validation if it exists
    if [[ -f "$INSTALL_DIR/generated/validation_suite.sh" ]]; then
        cd "$INSTALL_DIR"
        bash generated/validation_suite.sh
    else
        print_warning "Validation suite not found - this is normal for a fresh installation"
        print_info "Run the documentation parser to generate validation scripts"
    fi
    
    print_success "Validation complete"
}

# Create desktop entry (optional)
create_desktop_entry() {
    if command -v xdg-desktop-menu &> /dev/null; then
        print_header "Creating Desktop Entry"
        
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
    echo "3. Run validation (optional):"
    echo "   ./lfs-validate"
    echo ""
    echo "4. Parse documentation and generate build scripts:"
    echo "   python3 -m src.parsers.lfs_parser docs/lfs-git/chapter01/chapter01.xml"
    echo ""
    echo "5. Start a build:"
    echo "   ./lfs-build"
    echo ""
    
    echo -e "${YELLOW}Available commands:${NC}"
    echo "  ./lfs-validate  - Run validation suite"
    echo "  ./lfs-build     - Start LFS build process"
    echo "  ./lfs-test      - Run test suite"
    echo "  ./lfs-clean     - Clean build artifacts"
    echo ""
    
    echo -e "${YELLOW}Configuration:${NC}"
    echo "  Edit $INSTALL_DIR/lfs-builder.env to modify settings"
    echo "  See SETUP.md for detailed configuration options"
    echo ""
    
    echo -e "${YELLOW}Documentation:${NC}"
    echo "  README.md  - Quick start guide"
    echo "  SETUP.md   - Detailed setup and configuration"
    echo "  AGENTS.md  - Advanced usage"
    echo ""
    
    echo -e "${RED}Important Notes:${NC}"
    echo "• LFS building requires root privileges for certain operations"
    echo "• Ensure you have at least 50GB free disk space"
    echo "• The build process can take several hours to complete"
    echo "• Read the documentation thoroughly before starting a build"
    echo ""
    
    echo -e "${GREEN}Happy building!${NC}"
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

    print_info "This script will install Auto-LFS-Builder and its dependencies"
    print_info "Installation directory: $INSTALL_DIR"
    print_info "Workspace directory: $LFS_WORKSPACE"
    echo ""
    
    # Run installation steps
    check_root
    check_system_requirements
    install_system_dependencies
    setup_repository
    install_python_dependencies
    create_configuration
    create_scripts
    run_validation
    create_desktop_entry
    display_instructions
    
    print_success "Installation completed successfully!"
}

# Run main function
main "$@"
