# Auto-LFS-Builder

Auto-LFS-Builder is a documentation-driven automation project that converts the
guides located in `docs/` into scripts capable of creating a complete Linux From
Scratch system with networking and a GNOME desktop. The goal is to produce
self-installing media that can bootstrap a full system with minimal manual
interaction.

## Documentation Sources

The `docs/` directory provides all build instructions:

- `lfs-git` – the official Linux From Scratch book.
- `blfs-git` – Beyond LFS extensions and packages.
- `glfs` – GNOME desktop build instructions.
- `jhalfs` – helper scripts and automation framework.

Read these references to understand how each component is built.

## Prerequisites

- A Linux host with standard development tools (`bash`, `gcc`, `make`, `bison`,
  `flex`, `wget`, `curl`, `git`, etc.).
- At least 50\u202fGB of free disk space and 4\u202fGB of RAM.
- Internet access for downloading sources.
- Optionally, a virtualization environment (e.g. QEMU or KVM) for testing.

## Basic Setup

1. Clone the repository and enter the project directory.
2. Source the environment configuration file:

   ```bash
   source ./setup.sh
   ```

   This exports variables controlling where sources are located, the build
   profile, security settings, and other options.

3. Review and adjust the variables to match your system requirements.
4. Invoke the automation script to start the build process:

   ```bash
   ./generated/complete_build.sh
   ```

   The script orchestrates the entire build based on the instructions found in
   `docs/`.

## Development Status

This project is in active development. Script generation logic is evolving, and
new features will be added as the documentation processing improves.
