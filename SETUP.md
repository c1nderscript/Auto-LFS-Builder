# Auto-LFS-Builder Environment Configuration

## Overview
This document describes all environment variables, configuration options, and setup procedures for the Auto-LFS-Builder project. This system generates complete Linux From Scratch automation scripts by processing documentation sources and creating self-installing systems with GNOME desktop environments.

## Core LFS Build Variables

### Essential LFS Environment Variables
- **`LFS`**: Mount point for LFS build system (default: `/mnt/lfs`)
- **`LFS_TGT`**: Target triplet for cross-compilation (auto-detected: `$(uname -m)-lfs-linux-gnu`)
- **`LFS_MAKEFLAGS`**: Parallel compilation flags (default: `-j$(nproc)`)
- **`LFS_WORKSPACE`**: Alternative workspace for non-root builds (default: `./workspace/lfs-build`)

### Documentation Processing Variables
- **`DOCS_ROOT`**: Source documentation directory (default: `./docs`)
- **`GENERATED_DIR`**: Generated automation scripts directory (default: `./generated`)
- **`PARSING_LOG_LEVEL`**: Documentation parsing verbosity (`DEBUG`, `INFO`, `WARN`, `ERROR`)
- **`VALIDATION_MODE`**: Documentation validation strictness (`strict`, `permissive`)

### Build Configuration Variables
- **`BUILD_PROFILE`**: System build configuration profile
  - `desktop_gnome`: Full GNOME desktop with networking
  - `minimal`: Base LFS system only
  - `server`: Server configuration with networking, no GUI
  - `developer`: Development tools and environment
- **`TARGET_ARCH`**: Target system architecture (`x86_64`, `aarch64`)
- **`PARALLEL_JOBS`**: Build parallelization (`auto`, specific number)
- **`BUILD_OPTIMIZATION`**: Compilation optimization level (`-O2`, `-O3`, `-Os`)

### Component Control Flags
- **`ENABLE_GNOME`**: Install GNOME desktop environment (`true`/`false`)
- **`ENABLE_NETWORKING`**: Configure network stack and tools (`true`/`false`)
- **`ENABLE_MULTIMEDIA`**: Include multimedia codecs and tools (`true`/`false`)
- **`ENABLE_DEVELOPMENT_TOOLS`**: Include compilers and dev tools (`true`/`false`)
- **`ENABLE_VIRTUALIZATION`**: Support for VM/container tools (`true`/`false`)

### Security and Verification Settings
- **`VERIFY_PACKAGES`**: Enable GPG signature verification (`true`/`false`)
- **`CHECKSUM_VALIDATION`**: Validate package checksums (`sha256`, `all`, `none`)
- **`SECURITY_HARDENING`**: Apply security hardening flags (`true`/`false`)
- **`TRUSTED_KEYRING`**: GPG keyring for package verification

## Environment-Specific Configurations

### Development Environment
```bash
# Local development setup for testing automation
export LFS_WORKSPACE="$(pwd)/workspace/lfs-build"
export BUILD_PROFILE="desktop_gnome"
export PARALLEL_JOBS="auto"
export PARSING_LOG_LEVEL="DEBUG"
export VALIDATION_MODE="strict"
export ENABLE_GNOME="true"
export ENABLE_NETWORKING="true"
export ENABLE_DEVELOPMENT_TOOLS="true"
export VERIFY_PACKAGES="true"
export CHECKSUM_VALIDATION="sha256"
```

### Production Build Environment
```bash
# Production LFS build configuration
export LFS="/mnt/lfs"
export BUILD_PROFILE="desktop_gnome"
export PARALLEL_JOBS="$(nproc)"
export PARSING_LOG_LEVEL="INFO"
export VALIDATION_MODE="strict"
export ENABLE_GNOME="true"
export ENABLE_NETWORKING="true"
export ENABLE_MULTIMEDIA="true"
export SECURITY_HARDENING="true"
export VERIFY_PACKAGES="true"
export CHECKSUM_VALIDATION="all"
```

### CI/CD Testing Environment
```bash
# Continuous integration testing
export LFS="/tmp/lfs-ci-build"
export BUILD_PROFILE="minimal"
export PARALLEL_JOBS="2"
export PARSING_LOG_LEVEL="DEBUG"
export VALIDATION_MODE="permissive"
export ENABLE_GNOME="false"
export ENABLE_NETWORKING="true"
export VERIFY_PACKAGES="false"  # Speed up CI builds
export CHECKSUM_VALIDATION="sha256"
```

### Virtual Machine Testing
```bash
# VM testing environment
export LFS="/mnt/lfs-vm"
export BUILD_PROFILE="desktop_gnome"
export PARALLEL_JOBS="4"
export PARSING_LOG_LEVEL="INFO"
export VM_MEMORY="4G"
export VM_DISK_SIZE="50G"
export VM_TEST_GRAPHICS="true"
export VM_TEST_NETWORKING="true"
```

## Hardware-Specific Configuration

### x86_64 Desktop Configuration
```bash
export TARGET_ARCH="x86_64"
export CPU_FAMILY="x86_64"
export ENABLE_GRAPHICS_DRIVERS="intel,amd,nvidia"
export ENABLE_WIRELESS="true"
export ENABLE_BLUETOOTH="true"
export ENABLE_AUDIO="pulseaudio,pipewire"
export GRAPHICS_BACKEND="wayland,x11"
export FIRMWARE_SUPPORT="uefi,bios"
```

### ARM64/AArch64 Configuration
```bash
export TARGET_ARCH="aarch64"
export CPU_FAMILY="arm64"
export CROSS_COMPILE="aarch64-linux-gnu-"
export ENABLE_GRAPHICS_DRIVERS="arm,mali,adreno"
export ENABLE_WIRELESS="true"
export ENABLE_BLUETOOTH="true"
export GRAPHICS_BACKEND="wayland"
export FIRMWARE_SUPPORT="uefi"
```

### Raspberry Pi Specific
```bash
export TARGET_ARCH="aarch64"
export BOARD_TYPE="raspberry_pi_4"
export ENABLE_GRAPHICS_DRIVERS="broadcom"
export ENABLE_GPIO="true"
export ENABLE_CAMERA="true"
export BOOT_PARTITION_SIZE="256M"
export GPU_MEMORY_SPLIT="64"
```

## Performance and Resource Management

### Build Optimization Settings
```bash
# Adjust based on available system resources
export MAX_PARALLEL_JOBS="$(nproc)"
export BUILD_MEMORY_LIMIT="8G"
export TMPFS_BUILD_DIR="true"        # Use tmpfs for faster builds
export TMPFS_SIZE="4G"               # Size of tmpfs for builds
export CCACHE_ENABLED="true"         # Enable compilation cache
export CCACHE_SIZE="10G"             # Compilation cache size
export LINK_TIME_OPTIMIZATION="true" # Enable LTO for smaller binaries
```

### Disk and Storage Management
```bash
export PACKAGE_CACHE_DIR="/var/cache/lfs-packages"
export BUILD_CACHE_DIR="/var/cache/lfs-builds"
export LOG_RETENTION_DAYS="30"
export CLEANUP_BUILD_DIRS="true"     # Clean intermediate build dirs
export COMPRESS_LOGS="true"          # Compress old log files
export PACKAGE_MIRROR="https://www.linuxfromscratch.org/lfs/downloads/"
```

### Memory and Process Limits
```bash
export MAX_BUILD_MEMORY="6G"         # Per-build memory limit
export MAX_LINK_MEMORY="4G"          # Linker memory limit
export SWAP_MANAGEMENT="auto"        # Automatic swap management
export OOM_PROTECTION="true"         # Enable OOM protection
export PROCESS_NICE_LEVEL="10"       # Build process nice level
```

## Documentation Processing Configuration

### Parser Behavior Settings
```bash
export DOC_PARSER_TIMEOUT="300"      # Parser timeout in seconds
export DEPENDENCY_ANALYSIS="deep"    # Depth of dependency analysis
export CROSS_REFERENCE="true"        # Enable cross-reference validation
export EXTRACT_EXAMPLES="true"       # Extract code examples from docs
export VALIDATE_URLS="true"          # Validate documentation URLs
export CACHE_PARSED_DATA="true"      # Cache parsed documentation
```

### Code Generation Settings
```bash
export SCRIPT_TEMPLATE_DIR="templates/"
export GENERATED_SCRIPT_PREFIX="autogen_"
export INCLUDE_DEBUG_INFO="true"     # Include debug info in scripts
export SCRIPT_VALIDATION="strict"    # Validate generated scripts
export ERROR_HANDLING_LEVEL="comprehensive"
export LOGGING_VERBOSITY="detailed"
```

## Network and Download Configuration

### Package Download Settings
```bash
export DOWNLOAD_TIMEOUT="300"        # Download timeout in seconds
export DOWNLOAD_RETRIES="3"          # Number of download retries
export PARALLEL_DOWNLOADS="4"        # Concurrent downloads
export BANDWIDTH_LIMIT="0"           # Bandwidth limit (0=unlimited)
export MIRROR_SELECTION="auto"       # Automatic mirror selection
export PACKAGE_SIGNATURE_CHECK="mandatory"
```

### Proxy and Network Settings
```bash
# Uncomment and configure if using proxy
# export HTTP_PROXY="http://proxy.example.com:8080"
# export HTTPS_PROXY="http://proxy.example.com:8080"
# export FTP_PROXY="ftp://proxy.example.com:2121"
# export NO_PROXY="localhost,127.0.0.1,*.local"

export DNS_SERVERS="8.8.8.8,1.1.1.1"
export NETWORK_TIMEOUT="30"
export CONNECTION_RETRIES="3"
```

## GNOME Desktop Configuration

### GNOME Component Selection
```bash
export GNOME_VERSION="44"            # Target GNOME version
export GNOME_COMPONENTS="core,apps"  # GNOME components to install
export GNOME_SHELL_EXTENSIONS="true" # Enable shell extensions
export GNOME_THEMES="adwaita"        # Default theme selection
export GNOME_DISPLAY_MANAGER="gdm"   # Display manager choice
```

### Desktop Environment Settings
```bash
export WAYLAND_ENABLED="true"        # Enable Wayland support
export X11_FALLBACK="true"           # X11 fallback support
export HARDWARE_ACCELERATION="true"  # Enable hardware acceleration
export FONT_RENDERING="freetype"     # Font rendering engine
export ACCESSIBILITY_SUPPORT="true"  # Accessibility features
```

### Application Selection
```bash
export INCLUDE_FIREFOX="true"        # Include Firefox browser
export INCLUDE_LIBREOFFICE="false"   # Include LibreOffice suite
export INCLUDE_DEVELOPMENT_TOOLS="true"
export INCLUDE_MULTIMEDIA_APPS="true"
export INCLUDE_GAMES="false"
export INCLUDE_ADDITIONAL_APPS="web-browsers,text-editors"
```

## Testing and Validation Configuration

### Build Testing Settings
```bash
export ENABLE_BUILD_TESTS="true"     # Enable build-time testing
export TEST_COVERAGE="comprehensive" # Test coverage level
export PERFORMANCE_TESTS="true"      # Enable performance testing
export REGRESSION_TESTS="true"       # Enable regression testing
export INTEGRATION_TESTS="true"      # Enable integration testing
```

### Virtual Machine Testing
```bash
export VM_TESTING_ENABLED="true"
export VM_ENGINE="qemu"              # VM engine (qemu, virtualbox)
export VM_MEMORY_SIZE="4G"           # VM memory allocation
export VM_DISK_SIZE="50G"            # VM disk size
export VM_CPU_CORES="4"              # VM CPU cores
export VM_GRAPHICS_TEST="true"       # Test graphics in VM
export VM_NETWORK_TEST="true"        # Test networking in VM
export VM_BOOT_TEST="true"           # Test boot process
```

### Hardware Compatibility Testing
```bash
export HW_COMPAT_TESTING="true"
export TEST_GRAPHICS_DRIVERS="intel,amd,nvidia"
export TEST_WIRELESS_CHIPS="intel,broadcom,realtek"
export TEST_AUDIO_SYSTEMS="alsa,pulseaudio,pipewire"
export TEST_USB_DEVICES="true"
export TEST_STORAGE_DEVICES="sata,nvme,usb"
```

## Security and Hardening Configuration

### Build Security Settings
```bash
export SECURITY_LEVEL="high"         # Security hardening level
export ENABLE_PIE="true"             # Position Independent Executables
export ENABLE_STACK_PROTECTION="true"
export ENABLE_FORTIFY_SOURCE="true"
export ENABLE_RELRO="true"           # Relocation Read-Only
export STRIP_DEBUG_SYMBOLS="true"    # Strip debug symbols
```

### Package Verification Settings
```bash
export GPG_VERIFICATION="mandatory"  # GPG signature verification
export CHECKSUM_ALGORITHMS="sha256,sha512"
export TRUSTED_SOURCES_ONLY="true"   # Only trusted package sources
export VULNERABILITY_SCANNING="true" # Scan for known vulnerabilities
export SECURITY_UPDATES="auto"       # Automatic security updates
```

### System Hardening Options
```bash
export KERNEL_HARDENING="true"       # Kernel hardening options
export FIREWALL_ENABLED="true"       # Enable firewall by default
export SELINUX_ENABLED="false"       # SELinux support (experimental)
export APPARMOR_ENABLED="false"      # AppArmor support (experimental)
export SECURE_BOOT="auto"            # Secure boot configuration
```

## Debugging and Development Options

### Debug Build Settings
```bash
export DEBUG_BUILD="false"           # Enable debug build mode
export KEEP_BUILD_SOURCES="false"    # Keep source directories after build
export PRESERVE_INTERMEDIATE="false" # Keep intermediate build files
export VERBOSE_OUTPUT="false"        # Verbose build output
export TRACE_EXECUTION="false"       # Trace script execution
export PROFILING_ENABLED="false"     # Enable build profiling
```

### Development Mode Settings
```bash
export DEVELOPMENT_MODE="false"      # Enable development features
export LIVE_DOCUMENTATION="false"    # Live documentation updates
export INTERACTIVE_DEBUGGING="false" # Interactive debug sessions
export BUILD_MONITORING="true"       # Real-time build monitoring
export PERFORMANCE_PROFILING="false" # Performance profiling
```

### Logging and Monitoring
```bash
export LOG_LEVEL="INFO"              # Global log level
export LOG_FORMAT="structured"       # Log format (structured, plain)
export LOG_TIMESTAMPS="true"         # Include timestamps in logs
export LOG_ROTATION="daily"          # Log rotation schedule
export METRICS_COLLECTION="true"     # Collect build metrics
export MONITORING_INTERVAL="60"      # Monitoring check interval (seconds)
```

## Troubleshooting Environment Variables

### Error Handling Configuration
```bash
export ERROR_HANDLING="fail_fast"    # Error handling strategy
export ERROR_RECOVERY="auto"         # Automatic error recovery
export BACKUP_RESTORE="true"         # Enable backup and restore
export CHECKPOINT_FREQUENCY="build"  # Checkpoint creation frequency
export ROLLBACK_ENABLED="true"       # Enable rollback capability
```

### Diagnostic Settings
```bash
export DIAGNOSTIC_MODE="false"       # Enable diagnostic mode
export SYSTEM_INFO_COLLECTION="true" # Collect system information
export BUILD_ANALYTICS="true"        # Build analytics and reporting
export ERROR_REPORTING="true"        # Automatic error reporting
export PERFORMANCE_METRICS="true"    # Performance metrics collection
```

## Environment Validation

### Required Tools Check
```bash
# Validation script for required tools
validate_environment() {
    local required_tools=(
        "bash" "gcc" "g++" "make" "bison" "flex" "gawk"
        "texinfo" "patch" "tar" "gzip" "bzip2" "xz"
        "wget" "curl" "git" "python3" "xmllint" "pandoc"
    )
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "ERROR: Required tool '$tool' not found"
            return 1
        fi
    done
    
    echo "All required tools are available"
    return 0
}
```

### Environment Health Check
```bash
# Check environment configuration
check_environment_health() {
    # Check disk space
    local available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=52428800  # 50GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        echo "WARNING: Insufficient disk space"
    fi
    
    # Check memory
    local available_memory=$(free -m | awk 'NR==2{print $7}')
    if [ "$available_memory" -lt 4096 ]; then
        echo "WARNING: Less than 4GB available memory"
    fi
    
    # Check documentation
    if [ ! -d "$DOCS_ROOT" ]; then
        echo "ERROR: Documentation directory not found: $DOCS_ROOT"
        return 1
    fi
    
    echo "Environment health check passed"
    return 0
}
```

## Quick Setup Commands

### Standard Desktop Build
```bash
# Quick setup for desktop GNOME build
source venv/bin/activate
export BUILD_PROFILE="desktop_gnome"
export ENABLE_GNOME="true"
export ENABLE_NETWORKING="true"
export PARALLEL_JOBS="$(nproc)"
./generated/complete_build.sh
```

### Minimal Server Build
```bash
# Quick setup for a headless server build
source venv/bin/activate
export BUILD_PROFILE="server"
export ENABLE_GNOME="false"
export ENABLE_NETWORKING="true"
export PARALLEL_JOBS="$(nproc)"
./generated/complete_build.sh
```

### Developer Build
```bash
# Quick setup including developer tools
source venv/bin/activate
export BUILD_PROFILE="developer"
export ENABLE_DEVELOPMENT_TOOLS="true"
export ENABLE_NETWORKING="true"
export PARALLEL_JOBS="$(nproc)"
./generated/complete_build.sh
```

### Validate the Environment
```bash
validate_environment && check_environment_health
```

## Testing Process

The repository provides a small validation suite and unit tests.
To execute them manually run:

```bash
# Validate the base system
ENABLE_GNOME=false bash generated/validation_suite.sh

# Run unit tests
bash tests/run_tests.sh
```

These commands are executed automatically in the GitHub Actions workflow
located at `.github/workflows/ci.yml`.
