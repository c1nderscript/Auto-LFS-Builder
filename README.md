# Auto-LFS-Builder

An automated Linux From Scratch (LFS) builder that creates a complete LFS system without requiring document parsing.

This script builds:
- **Linux from Scratch** - Complete base system
- **GNOME Desktop** - Optional desktop environment
- **Networking** - Network configuration and tools
- **Development Tools** - Essential build tools and utilities

## 🚀 Quick Installation

The easiest way to install Auto-LFS-Builder is using the automated installation script:

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

**Arch Linux:**
```bash
sudo pacman -S base-devel bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils grep gzip m4 make patch sed tar xz
```

### 3. Configure environment

Edit `lfs-builder.env` to customize your build:

```bash
cp lfs-builder.env.example lfs-builder.env
# Edit the configuration file
nano lfs-builder.env
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

## ⚠️ Important Notes

**Please read before building:**

- The build process takes several hours (typically 3-8 hours depending on hardware)
- Ensure you have at least 50GB free disk space
- Do not interrupt the build process once started
- Review the configuration in `lfs-builder.env` before building
- Always run validation before starting a build
- The resulting system will need a bootloader to be bootable

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

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🤝 Support

For issues and questions:
1. Check the [documentation](SETUP.md) first
2. Run the validation suite to identify missing dependencies
3. Review the logs in the `logs/` directory
4. Open an issue on GitHub with detailed information

---

**Happy building!** 🎉
