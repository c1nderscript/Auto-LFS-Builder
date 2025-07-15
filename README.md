# Auto-LFS-Builder 🏗️ - FIXED VERSION

An automated Linux From Scratch (LFS) builder that creates a complete LFS system using Docker containers for reliability and reproducibility.

## 🚀 QUICK FIX APPLIED

**Critical issues have been resolved!** This version includes fixes for:
- ✅ Missing GCC dependencies (GMP, MPFR, MPC)
- ✅ Environment variable inconsistencies  
- ✅ Path configuration problems
- ✅ Docker volume mounting issues
- ✅ Missing core packages

## 🐳 Quick Start with Docker (Recommended)

The fastest and most reliable way to build LFS is using our Docker-based setup:

```bash
# Clone the repository
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder

# Start the build process (now with fixes applied)
docker compose up --build
```

That's it! The build will proceed automatically in a containerized environment with all dependencies properly configured.

## 🔧 Manual Fix Application (Optional)

If you have an older version, you can apply the fixes manually:

```bash
# Make the fix script executable and run it
chmod +x fix-lfs-builder.sh
./fix-lfs-builder.sh

# Then start the build
docker compose up --build
```

## ⚠️ Important Notes

- **Memory Requirements**: Ensure you have at least 8GB RAM available to Docker
- **Disk Space**: You need at least 50GB of free disk space
- **Build Time**: Expect 2-6 hours depending on your system specs
- **Parallel Jobs**: Now defaults to 16 jobs (reduced from 32 for stability)

## 🎯 What's Fixed

### Missing GCC Dependencies
The original script was missing critical packages needed to build GCC:
- Added `mpfr-4.2.1.tar.xz`
- Added `gmp-6.3.0.tar.xz`  
- Added `mpc-1.3.1.tar.gz`

### Environment Variables
Standardized all environment variable names:
- `ENABLE_GNOME` → `GNOME_ENABLED`
- `ENABLE_NETWORKING` → `NETWORKING_ENABLED`

### Additional Core Packages
Added missing essential packages:
- `diffutils-3.10.tar.xz`
- `patch-2.7.6.tar.xz`
- `xz-5.4.6.tar.xz`

### Docker Configuration
- Fixed volume mount paths
- Reduced parallel jobs for better stability
- Standardized environment variables

## 📋 Build Process

The build process follows these steps:

1. **Environment Setup** - Prepare build environment
2. **Package Download** - Download source packages (now includes all dependencies!)
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
- `./fix-lfs-builder.sh` - Apply critical fixes (if needed)

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
- **Resource limits**: Adjust Docker resource settings to at least 8GB RAM
- **Persistence**: Check volume permissions

### Direct Install Issues
- **Missing tools**: Run `./lfs-validate`
- **Disk space**: Ensure 50GB+ free
- **Memory**: Reduce `PARALLEL_JOBS` in `lfs-builder.env`

### Known Issues Fixed
- ❌ ~~GCC build fails due to missing dependencies~~ ✅ **FIXED**
- ❌ ~~Environment variable inconsistencies~~ ✅ **FIXED**
- ❌ ~~Missing core packages~~ ✅ **FIXED**
- ❌ ~~Docker volume mount issues~~ ✅ **FIXED**

## 🚀 System Requirements

### Docker Setup (Recommended)
- **OS**: Any OS that supports Docker
- **Docker**: Latest version
- **RAM**: 8GB minimum (16GB recommended)
- **Disk**: 50GB+ free space
- **CPU**: Multi-core recommended

### Direct Installation
- **OS**: Linux (x86_64 or aarch64)
- **Disk**: 50GB+ free space
- **RAM**: 4GB minimum (8GB recommended)
- **CPU**: Multi-core recommended
- **Network**: Internet connection

## 📚 Documentation

- [FIXES.md](FIXES.md) - Detailed information about what was fixed
- [SETUP.md](SETUP.md) - Detailed configuration
- [DOCKER.md](DOCKER.md) - Docker setup details

## 📄 License

MIT License - See [LICENSE](LICENSE) file

## 🤝 Support

1. Check this updated README
2. Review [FIXES.md](FIXES.md) for specific fixes applied
3. Check logs in `logs/` directory
4. Open GitHub issue with logs attached

---

**Happy building!** 🎉

*Note: This is the FIXED version of Auto-LFS-Builder with all critical issues resolved.*
