# Auto-LFS-Builder

Auto-LFS-Builder is a documentation‑driven automation system that converts the contents of the `docs/` directory into shell scripts capable of building a complete Linux From Scratch (LFS) desktop.

## Purpose

The project reads official LFS, BLFS, JHALFS and related manuals stored under `docs/` and produces repeatable build scripts in `generated/`. These scripts automate everything from toolchain setup to GNOME desktop installation so that a full system can be assembled with minimal manual intervention.

## Environment Configuration

Before generating scripts, configure your environment variables. The `setup.sh` file documents all supported options such as `LFS`, `BUILD_PROFILE` and `PARALLEL_JOBS`. Source it or adapt it to your needs.

A future `setup.md` will contain detailed walkthroughs, but for now you can review and customize `setup.sh` directly:

```bash
source setup.sh
```

## Directory Layout

```
src/        - Parsers, builders and installers that create automation
generated/  - Build scripts produced from the documentation
config/     - Configuration profiles and version settings
logs/       - Build logs
```

Documentation remains in `docs/` and should not be modified during a build. Generated scripts appear in `generated/` once the parsers run.

## Getting Started

1. Review the environment variables in `setup.sh` and tailor them for your system.
2. Ensure required tools (listed in `setup.sh`) are available.
3. Run the parsing and build helpers under `src/` to create scripts in `generated/`.
4. Execute `generated/complete_build.sh` (or similar) to start an automated LFS build.

For more advanced usage and update history, check `changelog.md` and the documentation inside `docs/`.
