# Auto-LFS-Builder 🏗️

An automated Linux From Scratch (LFS) builder that creates a complete LFS system using Docker containers for reliability and reproducibility.

## 🐳 Quick Start with Docker (Recommended)

The fastest and most reliable way to build LFS is using our Docker-based setup:

```bash
# Clone the repository
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder

# Start the build process
docker compose up --build
```

That's it! The build will proceed automatically in a containerized environment.

### Docker Setup Benefits

- ✅ **Consistent Environment** - Same build environment every time
- ✅ **Isolated Build** - No interference with host system
- ✅ **Persistent Storage** - Build progress saved between restarts
- ✅ **Resource Control** - Easy CPU and memory management
- ✅ **Zero Configuration** - Works out of the box
- ✅ **Cross-Platform** - Works on any Docker-capable system

### Docker Configuration

The default configuration in `docker-compose.yml` is optimized for most users, but you can customize:

- **CPU Cores**: Change `PARALLEL_JOBS` (default: all cores)
- **Build Profile**: Change `BUILD_PROFILE` (options: desktop_gnome, minimal, server, developer)
- **Features**: Toggle `GNOME_ENABLED`, `NETWORKING_ENABLED`, etc.
- **Logging**: Adjust log settings and verbosity

### Persistent Data

The Docker setup uses named volumes and bind mounts to preserve data:

- `./workspace`: Source packages and build artifacts
- `./logs`: Build logs and debug information
- `lfs_output`: Output system files (Docker volume)
- `lfs_mount`: LFS mount point (Docker volume)

## 🖥️ Direct System Installation (Alternative)

If you prefer to build directly on your system without Docker:

### System Requirements

- **OS**: Linux (x86_64 or aarch64)
- **Disk**: 50GB+ free space
- **RAM**: 4GB minimum (8GB recommended)
- **CPU**: Multi-core recommended
- **Network**: Internet connection

### Native Installation Steps

1. Install dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y build-essential bison flex gawk texinfo wget curl git

   # Fedora/RHEL
   sudo dnf install -y @development-tools bison flex gawk texinfo wget curl git

   # Arch Linux
   sudo pacman -S base-devel bison flex gawk texinfo wget curl git
   ```

2. Setup and build:
   ```bash
   git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
   cd Auto-LFS-Builder
   cp lfs-builder.env.example lfs-builder.env
   source activate
   ./lfs-validate
   ./lfs-build
   ```

## 📋 Build Process

The build process follows these steps:

1. **Environment Setup** - Prepare build environment
2. **Package Download** - Download source packages
3. **Cross-Compilation** - Build initial toolchain
4. **Core System** - Build base LFS system
5. **Configuration** - System setup and configuration
6. **Desktop** - Install GNOME (if enabled)
7. **Finalization** - Create system image

## 🔧 Available Commands

- `./lfs-validate` - Check requirements
- `./lfs-build` - Start the build
- `./lfs-test` - Run test suite
- `./lfs-clean` - Clean build files

## 📊 Build Profiles

- **desktop_gnome** (default): Full GNOME desktop
- **minimal**: Base LFS system only
- **server**: Networking, no GUI
- **developer**: Development tools

## 📝 Output Files

After building, you'll find:
- Complete system at `/mnt/lfs`
- System image at `workspace/lfs-system.tar.gz`
- Build logs in `logs/`

## 🐛 Troubleshooting

### Docker Issues
- **Build fails**: Check `docker compose logs`
- **Resource limits**: Adjust Docker resource settings
- **Persistence**: Check volume permissions

### Direct Install Issues
- **Missing tools**: Run `./lfs-validate`
- **Disk space**: Ensure 50GB+ free
- **Memory**: Reduce `PARALLEL_JOBS`

## 📚 Documentation

- [SETUP.md](SETUP.md) - Detailed configuration
- [DOCKER.md](DOCKER.md) - Docker setup details
- [MANUAL.md](MANUAL.md) - Manual build guide

## 📄 License

MIT License - See [LICENSE](LICENSE) file

## 🤝 Support

1. Check documentation
2. Review logs
3. Open GitHub issue

---

**Happy building!** 🎉
