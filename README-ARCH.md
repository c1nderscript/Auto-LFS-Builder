# Auto-LFS-Builder for Arch Linux

Quick start guide for Arch Linux users.

## Quick Installation

```bash
# Enhanced setup for Arch Linux
curl -sSL https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/scripts/arch-support.sh | bash

# Standard installation
curl -sSL https://raw.githubusercontent.com/c1nderscript/Auto-LFS-Builder/main/install.sh | bash
```

## Manual Installation

```bash
# Clone repository
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder

# Setup Arch Linux support
./scripts/arch-support.sh

# Install
./install.sh
```

## Usage

```bash
# Navigate to installation directory
cd ~/auto-lfs-builder

# Activate environment (with Arch optimizations)
source activate
source lfs-builder-arch.env

# Validate system
./lfs-validate
./scripts/arch-validation.sh

# Start building
./lfs-build
```

## Arch Linux Specific Features

### Enhanced Package Management
- Automatic pacman integration
- AUR helper support (yay, paru)
- Arch package mapping
- Dependency resolution

### Performance Optimizations
- ccache integration
- tmpfs build directory
- Arch compiler flags
- Multi-core compilation

### System Integration
- makepkg.conf integration
- Multilib support
- Arch-specific validation
- Build environment isolation

## Troubleshooting

```bash
# Run diagnostics
./scripts/arch-support.sh --troubleshoot

# Validate system
./scripts/arch-validation.sh

# Check logs
tail -f logs/arch-lfs-build.log
```

## Documentation

For complete documentation, see [docs/ARCH-LINUX.md](docs/ARCH-LINUX.md)

## Requirements

- Arch Linux (current)
- 50GB+ free space
- 4GB+ RAM (8GB+ recommended)
- Internet connection
- base-devel package group

## Support

- GitHub Issues: [Report problems](https://github.com/c1nderscript/Auto-LFS-Builder/issues)
- Arch Forums: [Community support](https://bbs.archlinux.org/)
