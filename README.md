# Auto-LFS-Builder 🏗️

[![CI Status](https://github.com/c1nderscript/Auto-LFS-Builder/workflows/CI/badge.svg)](https://github.com/c1nderscript/Auto-LFS-Builder/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/github/v/release/c1nderscript/Auto-LFS-Builder)](https://github.com/c1nderscript/Auto-LFS-Builder/releases)

An automated Linux From Scratch (LFS) builder that creates a complete LFS system using Docker containers for reliability and reproducibility.

## 📑 Table of Contents

- [Quick Start](#-quick-start-with-docker-recommended)
- [Features](#-features)
- [Requirements](#-system-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Build Profiles](#-build-profiles)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [Support](#-support)
- [License](#-license)

## 🚀 Quick Start with Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder

# Start the build process
docker compose up --build
```

## ✨ Features

- 🐳 **Docker-based**: Reliable and reproducible builds
- 🛠️ **Automated**: Full LFS system with minimal intervention
- 🎯 **Flexible**: Multiple build profiles for different needs
- 📊 **Monitored**: Build progress tracking and logging
- 🔄 **Resumable**: Can continue from interruptions
- 🧪 **Validated**: Comprehensive testing suite

## 💻 System Requirements

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

## 📦 Installation

### Docker (Recommended)
```bash
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder
docker compose up --build
```

### Manual
```bash
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder
./lfs-validate  # Check requirements
./lfs-build    # Start building
```

## 🔧 Usage

Available commands:
- `./lfs-validate` - Check requirements
- `./lfs-build` - Start the build
- `./lfs-test` - Run test suite
- `./lfs-clean` - Clean build files

## 📋 Build Profiles

- **desktop_gnome** (default): Full GNOME desktop
- **minimal**: Base LFS system only
- **server**: Networking, no GUI
- **developer**: Development tools

## ⚙️ Configuration

Environment variables in `lfs-builder.env`:
- `BUILD_PROFILE`: Build type (desktop_gnome, minimal, server, developer)
- `PARALLEL_JOBS`: Number of parallel build jobs
- `GNOME_ENABLED`: Enable GNOME desktop
- `NETWORKING_ENABLED`: Enable networking support

## 🔍 Troubleshooting

### Docker Issues
- **Build fails**: Check `docker compose logs`
- **Resource limits**: Adjust Docker resource settings
- **Persistence**: Check volume permissions

### Direct Install Issues
- **Missing tools**: Run `./lfs-validate`
- **Disk space**: Ensure 50GB+ free
- **Memory**: Reduce `PARALLEL_JOBS`

## 📚 Documentation

- [PROJECT_STATUS.md](PROJECT_STATUS.md) - Current project status
- [SETUP.md](SETUP.md) - Detailed configuration
- [DOCKER.md](DOCKER.md) - Docker setup details
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [SECURITY.md](SECURITY.md) - Security policy
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) - Code of conduct

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request

## 💬 Support

1. Check the documentation
2. Review troubleshooting guide
3. Check logs in `logs/` directory
4. Open GitHub issue with logs attached

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy building!** 🎉
