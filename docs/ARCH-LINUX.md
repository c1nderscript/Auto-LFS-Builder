# Arch Linux Setup Guide for Auto-LFS-Builder

This guide provides comprehensive instructions for setting up and using Auto-LFS-Builder on Arch Linux systems.

## Quick Start

### 1. Enhanced Installation

For Arch Linux users, we recommend using the enhanced installation process:

```bash
# Clone the repository
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder

# Run Arch Linux specific setup
./scripts/arch-support.sh

# Run the standard installation
./install.sh
```

### 2. Arch-Specific Configuration

After installation, source the Arch-specific configuration:

```bash
cd ~/auto-lfs-builder
source lfs-builder.env
source lfs-builder-arch.env  # Arch Linux optimizations
```

## System Requirements

### Hardware Requirements
- **CPU**: x86_64 architecture (recommended: 4+ cores)
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: 50GB+ free space on fast storage (SSD recommended)
- **Network**: Stable internet connection for downloading packages

### Software Requirements
- **Arch Linux**: Up-to-date installation
- **Kernel**: 5.4+ (recent kernels recommended)
- **Glibc**: 2.31+ (usually satisfied on current Arch)
- **GCC**: 9.0+ (usually satisfied on current Arch)

## Installation Methods

### Method 1: Automated Setup (Recommended)

```bash
# One-command setup
curl -sSL https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/scripts/arch-support.sh | bash
```

### Method 2: Manual Setup

1. **Install base dependencies**:
   ```bash
   sudo pacman -S --needed base-devel git wget curl gawk m4 texinfo bison flex bc cpio dosfstools parted rsync unzip which pkg-config autoconf automake libtool patch python python-pip
   ```

2. **Install LFS-specific tools**:
   ```bash
   sudo pacman -S --needed qemu-system-x86_64 arch-install-scripts xorriso libisoburn squashfs-tools mtools syslinux
   ```

3. **Install optional performance tools**:
   ```bash
   sudo pacman -S --needed ccache distcc ninja cmake meson
   ```

4. **Install AUR helper (optional but recommended)**:
   ```bash
   # Install yay
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   cd .. && rm -rf yay
   ```

## Arch Linux Optimizations

### Compiler Optimizations

Auto-LFS-Builder automatically reads your `/etc/makepkg.conf` and applies Arch-specific optimizations:

```bash
# View current compiler flags
grep -E '^(CFLAGS|CXXFLAGS|LDFLAGS)=' /etc/makepkg.conf

# Common Arch optimization flags
CFLAGS="-march=native -mtune=native -O2 -pipe -fstack-protector-strong"
CXXFLAGS="$CFLAGS"
LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"
```

### Build Performance

#### Using ccache
```bash
# Install and configure ccache
sudo pacman -S ccache
ccache --set-config=max_size=5G
ccache --set-config=compression=true

# ccache will be automatically used by Auto-LFS-Builder
```

#### Using tmpfs for builds
```bash
# Create tmpfs build directory (requires 8GB+ RAM)
sudo mkdir -p /tmp/lfs-build
sudo mount -t tmpfs -o size=4G,nodev,nosuid,noexec tmpfs /tmp/lfs-build
sudo chown $USER:$USER /tmp/lfs-build

# Export build directory
export LFS_BUILD_DIR=/tmp/lfs-build
```

### Multilib Support

If you need 32-bit compatibility:

```bash
# Enable multilib repository
sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
sudo pacman -Sy

# Install multilib development tools
sudo pacman -S lib32-glibc lib32-gcc-libs
```

## Configuration

### Environment Variables

Create or modify `lfs-builder-arch.env`:

```bash
# Arch Linux specific settings
export ARCH_LINUX=true
export BUILD_SYSTEM="arch"

# Performance settings
export USE_CCACHE=true
export CCACHE_SIZE="5G"
export PARALLEL_JOBS="$(nproc)"

# Build optimization
export MAKEFLAGS="-j$(nproc)"
export NINJA_STATUS="[%f/%t] "

# Use tmpfs if available
if [[ -d /tmp/lfs-build ]]; then
    export LFS_BUILD_DIR="/tmp/lfs-build"
fi
```

### Build Profiles

Arch Linux users can use these optimized build profiles:

#### Performance Profile
```bash
export BUILD_PROFILE="arch_performance"
export ENABLE_LTO=true
export CFLAGS="-march=native -mtune=native -O3 -pipe -flto"
export MAKEFLAGS="-j$(nproc)"
```

#### Minimal Profile
```bash
export BUILD_PROFILE="arch_minimal"
export ENABLE_GNOME=false
export ENABLE_MULTIMEDIA=false
export CFLAGS="-march=x86-64 -mtune=generic -Os -pipe"
```

## Usage

### Basic Usage

1. **Validate system**:
   ```bash
   ./scripts/arch-support.sh --validate
   ```

2. **Run LFS validation**:
   ```bash
   ./lfs-validate
   ```

3. **Start building**:
   ```bash
   ./lfs-build
   ```

### Advanced Usage

#### Custom Build Directory
```bash
# Use custom build directory
export LFS_WORKSPACE="/home/build/lfs-workspace"
./lfs-build
```

#### Build with Specific Options
```bash
# Build minimal system
export BUILD_PROFILE="minimal"
export ENABLE_GNOME=false
./lfs-build
```

#### Build with Maximum Performance
```bash
# Apply all optimizations
./scripts/arch-support.sh --optimize
source lfs-builder-arch.env
./lfs-build
```

## Troubleshooting

### Common Issues

#### 1. Package Not Found
```bash
# Update package database
sudo pacman -Sy

# Search for package
package_name="example"
pacman -Ss "$package_name"
yay -Ss "$package_name"  # if using AUR
```

#### 2. Compilation Errors
```bash
# Check system status
./scripts/arch-support.sh --troubleshoot

# Clear ccache if using
ccache --clear

# Check for missing dependencies
./lfs-validate
```

#### 3. Disk Space Issues
```bash
# Clean package cache
sudo pacman -Sc

# Clean build cache
rm -rf ~/.cache/yay
ccache --clear

# Check disk usage
df -h
du -sh ~/auto-lfs-builder/
```

#### 4. Memory Issues
```bash
# Check memory usage
free -h

# Reduce parallel jobs
export MAKEFLAGS="-j2"
export PARALLEL_JOBS=2

# Enable swap if needed
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Diagnostic Commands

```bash
# System validation
./scripts/arch-support.sh --validate

# Full troubleshooting
./scripts/arch-support.sh --troubleshoot

# Check LFS requirements
./lfs-validate

# Check build logs
tail -f logs/lfs-build.log
```

## Performance Tips

### 1. CPU Optimization
```bash
# Use native CPU optimizations
export CFLAGS="-march=native -mtune=native -O2 -pipe"
```

### 2. I/O Optimization
```bash
# For NVMe/SSD users
echo mq-deadline | sudo tee /sys/block/nvme0n1/queue/scheduler

# Use tmpfs for builds
export LFS_BUILD_DIR="/tmp/lfs-build"
```

### 3. Memory Optimization
```bash
# Enable memory compression
echo lz4 | sudo tee /sys/block/zram0/comp_algorithm

# Use faster memory allocator
export LD_PRELOAD="/usr/lib/libjemalloc.so.2"
```

## Advanced Configuration

### Custom Arch Repository

```bash
# Add custom repository to pacman.conf
sudo tee -a /etc/pacman.conf << 'EOF'
[custom]
Server = https://example.com/arch/$repo/$arch
EOF

sudo pacman -Sy
```

### Build Environment Isolation

```bash
# Use systemd-nspawn for isolated builds
sudo systemd-nspawn -D /var/lib/machines/lfs-build
```

### Cross-compilation Setup

```bash
# Install cross-compilation tools
sudo pacman -S cross-x86_64-linux-gnu-gcc
export CROSS_COMPILE=x86_64-linux-gnu-
```

## FAQ

### Q: Can I use Auto-LFS-Builder on Arch-based distributions?
**A:** Yes, it should work on Manjaro, EndeavourOS, and other Arch-based distributions. The script will detect the Arch base system.

### Q: How do I enable multilib support?
**A:** Edit `/etc/pacman.conf` and uncomment the `[multilib]` section, then run `sudo pacman -Sy`.

### Q: What if I encounter AUR package build failures?
**A:** First update your system with `sudo pacman -Syu`, then try rebuilding the AUR package. Consider using `yay` or `paru` instead of `yaourt`.

### Q: How can I speed up the build process?
**A:** Use ccache, tmpfs, enable LTO, and optimize your compiler flags. The arch-support script does most of this automatically.

### Q: Can I build LFS on a Raspberry Pi running Arch ARM?
**A:** The script is designed for x86_64 systems. ARM support would require modifications to the build process.

### Q: How do I clean up after a failed build?
**A:** Run `./lfs-clean` to remove build artifacts, and `ccache --clear` to clear the compile cache.

## Getting Help

- **GitHub Issues**: [Report bugs and issues](https://github.com/c1nderscript/Auto-LFS-Builder/issues)
- **Arch Linux Forums**: [Community support](https://bbs.archlinux.org/)
- **LFS Documentation**: [Official LFS guide](http://www.linuxfromscratch.org/lfs/)

## Contributing

Contributions for Arch Linux improvements are welcome! Please:

1. Test on clean Arch Linux installations
2. Follow Arch Linux packaging guidelines
3. Update documentation for any changes
4. Submit pull requests with clear descriptions

## License

This documentation is part of the Auto-LFS-Builder project and follows the same license terms.