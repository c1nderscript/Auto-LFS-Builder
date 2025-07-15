# Auto-LFS-Builder

An automated Linux From Scratch (LFS) builder that creates a complete LFS system without requiring document parsing.

This script builds:
- **Linux from Scratch** - Complete base system
- **GNOME Desktop** - Optional desktop environment
- **Networking** - Network configuration and tools
- **Development Tools** - Essential build tools and utilities

## 🏗️ Enhanced Arch Linux Support

Auto-LFS-Builder now includes comprehensive **Arch Linux optimizations** for the best possible experience:

### ⚡ Performance Optimizations
- **ccache integration** - Faster rebuilds with compile caching
- **tmpfs builds** - RAM-based compilation for speed
- **Arch compiler flags** - Optimized for your CPU architecture
- **Multi-core compilation** - Parallel builds using all CPU cores

### 🛠️ Arch-Specific Features
- **Automatic pacman integration** - Seamless package management
- **AUR helper support** - Works with yay, paru, and other AUR helpers
- **Package mapping** - Intelligent translation of package names
- **System validation** - Comprehensive Arch Linux compatibility checks

### 📖 Arch Linux Documentation
- [docs/ARCH-LINUX.md](docs/ARCH-LINUX.md) - Complete Arch Linux setup guide
- [README-ARCH.md](README-ARCH.md) - Quick start for Arch users

## 🚀 Quick Installation

### For Arch Linux Users (Recommended)

```bash
# Enhanced setup with Arch Linux optimizations
curl -sSL https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/scripts/arch-support.sh | bash

# Standard installation
curl -sSL https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/install.sh | bash
```

### For All Linux Distributions

```bash
curl -sSL https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/install.sh | bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/install.sh
chmod +x install.sh
./install.sh
```

### Installation Options

The installation script supports several options:

```bash
./install.sh --help
```

Common options:
- `--install-dir DIR`: Set installation directory (default: `~/auto-lfs-builder`)
- `--workspace DIR`: Set workspace directory (default: `~/lfs-workspace`)
- `--build-profile NAME`: Choose build profile (`desktop_gnome`, `minimal`, `server`, `developer`)
- `--parallel-jobs N`: Set number of parallel build jobs (default: number of CPU cores)

## 📋 System Requirements

- **OS**: Linux (x86_64 or aarch64)
- **Disk Space**: At least 50GB available
- **Memory**: 4GB RAM recommended (minimum 2GB)
- **Network**: Internet connection for downloading packages
- **Time**: Several hours for complete build

### Arch Linux Specific Requirements
- **Arch Linux**: Current installation
- **base-devel**: Package group for development tools
- **Internet**: For downloading packages and AUR access

## 🔧 Manual Installation

If you prefer to install manually:

### 1. Clone the repository

```bash
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder
```

### 2. Install system dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y build-essential bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils grep gzip m4 make patch sed tar xz-utils
```

**Fedora/RHEL:**
```bash
sudo dnf install -y @development-tools bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils grep gzip m4 make patch sed tar xz
```

**Arch Linux (Enhanced):**
```bash
# Run the enhanced Arch Linux setup
./scripts/arch-support.sh

# Or install manually
sudo pacman -S base-devel bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils grep gzip m4 make patch sed tar xz
```

### 3. Configure environment

Edit `lfs-builder.env` to customize your build:

```bash
cp lfs-builder.env.example lfs-builder.env
# Edit the configuration file
nano lfs-builder.env
```

For **Arch Linux users**, also configure Arch-specific settings:
```bash
# Arch Linux users get additional configuration
nano lfs-builder-arch.env
```

## 🚀 Quick Start

After installation:

1. **Navigate to installation directory:**
   ```bash
   cd ~/auto-lfs-builder
   ```

2. **Activate the environment:**
   ```bash
   source activate
   ```

3. **Run validation (recommended):**
   ```bash
   ./lfs-validate
   ```

4. **Start building LFS:**
   ```bash
   ./lfs-build
   ```

### Arch Linux Quick Start

For Arch Linux users, additional commands are available:

```bash
# Validate Arch Linux system
./scripts/arch-validation.sh

# Apply performance optimizations
./scripts/arch-support.sh --optimize

# Run troubleshooting diagnostics
./scripts/arch-support.sh --troubleshoot
```

## 📊 Build Profiles

The system supports several build profiles:

- **`desktop_gnome`** *(default)*: Full GNOME desktop with networking and multimedia support
- **`minimal`**: Base LFS system only
- **`server`**: Server configuration with networking, no GUI
- **`developer`**: Development tools and environment

Change the build profile by editing `lfs-builder.env`:

```bash
export BUILD_PROFILE="minimal"
```

## 🛠️ Available Commands

After installation, you'll have access to these convenience commands:

- `./lfs-validate` - Run validation suite to check required tools
- `./lfs-build` - Start the complete LFS build process
- `./lfs-test` - Run test suite (if available)
- `./lfs-clean` - Clean build artifacts and temporary files

### Arch Linux Specific Commands

- `./scripts/arch-support.sh --validate` - Validate Arch Linux system
- `./scripts/arch-support.sh --optimize` - Apply performance optimizations
- `./scripts/arch-support.sh --troubleshoot` - Run diagnostics
- `./scripts/arch-validation.sh` - Comprehensive Arch Linux validation

## 📖 Build Process

The build process follows these main steps:

1. **Environment Setup** - Prepare build environment and directories
2. **Package Download** - Download source packages from official repositories
3. **Cross-Compilation Tools** - Build initial cross-compilation toolchain
4. **Kernel Headers** - Install Linux kernel headers
5. **Glibc** - Build and install the C library
6. **Core Tools** - Build essential system tools (bash, coreutils, etc.)
7. **System Configuration** - Configure users, networking, and system files
8. **Desktop Environment** - Install GNOME (if enabled)
9. **Finalization** - Create bootable system image

For **Arch Linux users**, the build process is enhanced with:
- Optimized compiler flags from your `/etc/makepkg.conf`
- ccache integration for faster rebuilds
- tmpfs usage for RAM-based compilation
- Parallel processing optimized for your CPU

## 🔧 Configuration

### Environment Variables

Edit `lfs-builder.env` to customize your build:

```bash
# Core LFS Build Variables
export LFS_WORKSPACE="${HOME}/lfs-workspace"
export BUILD_PROFILE="desktop_gnome"
export PARALLEL_JOBS="4"

# Component Control Flags
export ENABLE_GNOME="true"
export ENABLE_NETWORKING="true"
export ENABLE_MULTIMEDIA="true"
export ENABLE_DEVELOPMENT_TOOLS="true"

# Security and Verification
export VERIFY_PACKAGES="true"
export CHECKSUM_VALIDATION="sha256"
export SECURITY_HARDENING="true"
```

### Arch Linux Configuration

Arch Linux users get additional configuration in `lfs-builder-arch.env`:

```bash
# Arch Linux optimizations
export ARCH_LINUX=true
export USE_CCACHE=true
export CCACHE_SIZE="5G"
export ENABLE_TMPFS="auto"
export PARALLEL_JOBS="$(nproc)"
```

### Build Profiles

You can create custom build profiles by modifying the build script or environment variables.

## 📝 Output

After a successful build, you'll find:

- **LFS System**: Complete file system at `$LFS_WORKSPACE/lfs/`
- **System Image**: Compressed system image at `$LFS_WORKSPACE/lfs-system.tar.gz`
- **Build Logs**: Detailed logs in the `logs/` directory

## 🔍 Validation

Always run validation before building:

```bash
./lfs-validate
```

This checks for:
- Required build tools (gcc, make, bash, etc.)
- System requirements (disk space, memory)
- Environment configuration
- Network connectivity

**Arch Linux users** also have enhanced validation:
```bash
./scripts/arch-validation.sh
```

## 🧪 Testing

After building, you can test your LFS system:

1. **Create a Virtual Machine** or prepare a test machine
2. **Extract the system image** to the target disk
3. **Install a bootloader** (GRUB recommended)
4. **Boot your new LFS system**

## 📚 Documentation

- [README.md](README.md) - This file (quick start guide)
- [SETUP.md](SETUP.md) - Detailed setup and configuration
- [AGENTS.md](AGENTS.md) - Advanced usage and automation

### Arch Linux Documentation
- [docs/ARCH-LINUX.md](docs/ARCH-LINUX.md) - Comprehensive Arch Linux guide
- [README-ARCH.md](README-ARCH.md) - Quick start for Arch users
- [config/arch-linux.conf](config/arch-linux.conf) - Arch Linux configuration template

## Scheduled Documentation Updates

A GitHub Actions workflow runs nightly to update the documentation and regenerate all build scripts. The results are logged to `logs/parsing_logs/` and uploaded as workflow artifacts.


## Important Notes

**Please read before building:**

- The build process takes several hours (typically 3-8 hours depending on hardware)
- Ensure you have at least 50GB free disk space
- Do not interrupt the build process once started
- Review the configuration in `lfs-builder.env` before building
- Always run validation before starting a build
- The resulting system will need a bootloader to be bootable

**For Arch Linux users:**
- Enhanced build performance with automatic optimizations
- ccache and tmpfs can significantly speed up builds
- System validation is more comprehensive
- AUR helper integration provides additional packages

## 🎯 Next Steps After Building

1. **Create a bootable disk** or VM
2. **Extract the system image**:
   ```bash
   cd /mnt/lfs  # Your target mount point
   tar -xzf ~/lfs-workspace/lfs-system.tar.gz
   ```
3. **Install GRUB bootloader**:
   ```bash
   grub-install --target=i386-pc /dev/sdX
   grub-mkconfig -o /boot/grub/grub.cfg
   ```
4. **Boot your new LFS system**

## 🐛 Troubleshooting

Common issues and solutions:

- **Build fails**: Check `logs/` directory for detailed error messages
- **Missing tools**: Run `./lfs-validate` to check required dependencies
- **Disk space**: Ensure you have sufficient free space (50GB+)
- **Memory issues**: Reduce `PARALLEL_JOBS` for systems with limited RAM

### Arch Linux Specific Troubleshooting

```bash
# Run comprehensive diagnostics
./scripts/arch-support.sh --troubleshoot

# Check system compatibility
./scripts/arch-validation.sh

# View Arch-specific logs
tail -f logs/arch-lfs-build.log
```

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🤝 Support

For issues and questions:
1. Check the [documentation](SETUP.md) first
2. **Arch Linux users**: See [docs/ARCH-LINUX.md](docs/ARCH-LINUX.md)
3. Run the validation suite to identify missing dependencies
4. Review the logs in the `logs/` directory
5. Open an issue on GitHub with detailed information

### Arch Linux Support
- [Arch Linux Forums](https://bbs.archlinux.org/) - Community support
- [Arch Wiki](https://wiki.archlinux.org/) - Comprehensive documentation
- Run `./scripts/arch-support.sh --troubleshoot` for system diagnostics

---

**Happy building!** 🎉

*Special thanks to the Arch Linux community for their excellent documentation and tools that made these optimizations possible.*
