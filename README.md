# Auto-LFS-Builder

An automated linux from scratch builder.

This script builds:

Linux from Scratch

Beyond Linux from Scratch

Gaming on Linux from Scratch


All in one application.
See [setup.md](setup.md) for environment configuration details.

## Getting Started

Use the desktop GNOME build profile as a starting point:

```bash
source config/build_profiles/desktop_gnome.conf
./generated/complete_build.sh
```

This loads environment variables such as `ENABLE_GNOME`, `ENABLE_NETWORKING`, and
`PARALLEL_JOBS` so the build runs with a full GNOME desktop.
