# Auto-LFS-Builder

An automated linux from scratch builder.

This script builds:

Linux from Scratch

Beyond Linux from Scratch

Gaming on Linux from Scratch


All in one application.
See [setup.md](setup.md) for environment configuration details.

## Repository Layout

- `docs/` - source LFS, BLFS, JHALFS and GLFS documentation
- `src/` - parsers and builders that process documentation
- `generated/` - build scripts produced by the parsers
- `config/` - configuration files and build profiles
- `logs/` - logs from parsing and build runs

## Prerequisites

Install the base packages required for documentation processing and building:

```bash
sudo apt-get install -y python3 python3-pip xmllint pandoc \
    build-essential bison gawk texinfo wget curl git
pip3 install beautifulsoup4 lxml requests
```

See the [setup guide](setup.md) for a complete list of variables and options.

## Quick Start

1. Configure your environment following the instructions in [setup.md](setup.md).
2. Run the main workflow:

```bash
./generated/complete_build.sh
```

The script reads the documentation under `docs/` and builds a bootable system in one pass.

## Updating Documentation and Regenerating Scripts

To refresh the build scripts after pulling new documentation:

```bash
cd docs/lfs-git && git pull
cd ../blfs-git && git pull
cd ../jhalfs && git pull
cd ../glfs && git pull
../src/parsers/regenerate_all_scripts.sh
```

This will regenerate `generated/complete_build.sh` and all supporting scripts.

