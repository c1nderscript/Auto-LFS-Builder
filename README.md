# Auto-LFS-Builder

An automated linux from scratch builder.

This script builds:

Linux from Scratch

Beyond Linux from Scratch

Gaming on Linux from Scratch


All in one application.

## Build System

A top-level `Makefile` orchestrates the build process. Run `make` to parse the documentation, generate the build scripts, and execute validation routines.

```bash
make
```

Each stage can be invoked individually with `make parse`, `make generate`, or `make validate`.
