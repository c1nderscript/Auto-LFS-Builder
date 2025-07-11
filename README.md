# Auto-LFS-Builder

Auto-LFS-Builder is a documentation-driven system for building **Linux From Scratch** with a complete GNOME desktop. Automation scripts are generated directly from the manuals stored under `docs/`.

## Directory Overview

- `docs/` - LFS, BLFS, JHALFS and GLFS documentation sources
- `src/` - parsers and build script generators
- `generated/` - auto-generated build scripts
- `config/` - build profiles and hardware settings
- `logs/` - parsing and build logs

## Running the Automation

1. Install prerequisites such as `python3`, `xmllint`, `pandoc`, `build-essential`, `wget`, `curl` and `git`.
2. Generate the build scripts:
   ```bash
   ./src/parsers/regenerate_all_scripts.sh
   ```
3. Launch the build process:
   ```bash
   sudo bash generated/complete_build.sh
   ```

The master script builds the base LFS system, sets up networking and installs the full GNOME desktop.

## Updating Documentation and Getting Help

Use the `update_documentation` routine described in [AGENTS.md](AGENTS.md) to pull the latest books. After updating, re-run the parsers to regenerate the scripts.

For more information and troubleshooting, see the documentation in `docs/` and consult `AGENTS.md`.

