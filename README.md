# Auto-LFS-Builder

An automated linux from scratch builder.

This script builds:

- Linux from Scratch
- Beyond Linux from Scratch
- Gaming on Linux from Scratch

All in one application.

## Quick Installation

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

## Manual Installation

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
sudo apt-get install -y build-essential bison flex gawk texinfo wget curl git python3 python3-pip python3-venv libxml2-utils pandoc
```

**Fedora/RHEL:**
```bash
sudo dnf install -y @development-tools bison flex gawk texinfo wget curl git python3 python3-pip libxml2 pandoc
```

### 3. Set up Python environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Configure environment

See [SETUP.md](SETUP.md) for detailed configuration options.

## Quick Start

After installation:

1. **Navigate to installation directory:**
   ```bash
   cd ~/auto-lfs-builder
   ```

2. **Activate the environment:**
   ```bash
   source activate
   ```

3. **Run validation (optional):**
   ```bash
   ./lfs-validate
   ```

4. **Parse documentation and generate build scripts:**
   ```bash
   python3 -m src.parsers.lfs_parser docs/lfs-git/chapter01/chapter01.xml
   ```

5. **Start a build:**
   ```bash
   ./lfs-build
   ```

## Build Profiles

The system supports several build profiles:

- **`desktop_gnome`**: Full GNOME desktop with networking and multimedia support
- **`minimal`**: Base LFS system only
- **`server`**: Server configuration with networking, no GUI
- **`developer`**: Development tools and environment

## System Requirements

- **OS**: Linux (x86_64 or aarch64)
- **Disk Space**: At least 50GB available
- **Memory**: 4GB RAM recommended (minimum 2GB)
- **Network**: Internet connection for downloading packages

## Validation

The repository includes a validation suite at `generated/validation_suite.sh`.
Run it to verify required tools are available before building:

```bash
bash generated/validation_suite.sh
```

## Available Commands

After installation, you'll have access to these convenience commands:

- `./lfs-validate` - Run validation suite
- `./lfs-build` - Start LFS build process
- `./lfs-test` - Run test suite
- `./lfs-clean` - Clean build artifacts

## Documentation

- [README.md](README.md) - This file (quick start guide)
- [SETUP.md](SETUP.md) - Detailed setup and configuration
- [AGENTS.md](AGENTS.md) - Advanced usage and agent documentation

## Scheduled Documentation Updates

A GitHub Actions workflow runs nightly to update the documentation and regenerate all build scripts. The results are logged to `logs/parsing_logs/` and uploaded as workflow artifacts.


## Important Notes

⚠️ **Please read before building:**

- LFS building requires root privileges for certain operations
- Ensure you have at least 50GB free disk space
- The build process can take several hours to complete
- Read the documentation thoroughly before starting a build
- Always run validation before attempting a build

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
1. Check the [documentation](SETUP.md) first
2. Run the validation suite to identify missing dependencies
3. Review the logs in the `logs/` directory
4. Open an issue on GitHub with detailed information
