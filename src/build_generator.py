#!/usr/bin/env python3
"""Simple build script generator."""

import sys
from pathlib import Path

from parsers.lfs_parser import extract_command_blocks


def main(chapter_paths):
    Path("generated").mkdir(exist_ok=True)
    out_path = Path("generated/complete_build.sh")
    with out_path.open("w", encoding="utf-8") as f:
        f.write("#!/bin/bash\n\n")
        for chapter in chapter_paths:
            for cmd in extract_command_blocks(chapter):
                f.write(cmd + "\n")
    out_path.chmod(0o755)
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 src/build_generator.py <chapter.xml> [more.xml ...]")
        sys.exit(1)
    main(sys.argv[1:])
