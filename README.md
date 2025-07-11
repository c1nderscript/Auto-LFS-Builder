# Auto-LFS-Builder

An automated linux from scratch builder.

This script builds:

Linux from Scratch

Beyond Linux from Scratch

Gaming on Linux from Scratch


All in one application.

## Generating Build Commands

A simple parser is available to extract build commands from the LFS
documentation.
Run it by pointing to the `docs/lfs-git` directory:

```bash
python3 src/parsers/lfs_parser.py docs/lfs-git
```

By default the parser writes the commands to `generated/lfs_commands.sh`
and also prints them to stdout so you can redirect them elsewhere if
needed:

```bash
python3 src/parsers/lfs_parser.py docs/lfs-git > generated/lfs_commands.sh
```
