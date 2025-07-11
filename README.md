# Auto-LFS-Builder

An automated linux from scratch builder.

This script builds:

Linux from Scratch

Beyond Linux from Scratch

Gaming on Linux from Scratch


All in one application.

## Generating Build Scripts

Use the build generator to parse chapter files and create a skeleton build script:

```bash
python3 src/build_generator.py docs/lfs-git/chapter02/mounting.xml
```

The script writes `generated/complete_build.sh` containing the extracted command blocks. More XML files can be provided as additional arguments.
