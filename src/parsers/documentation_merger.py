# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

"""Utilities for combining documentation sources."""

from __future__ import annotations

import argparse
from pathlib import Path


def merge_sources(sources: list[str | Path]) -> str:
    """Return the concatenation of all files in *sources*."""

    contents = []
    for src in sources:
        path = Path(src)
        if not path.exists():
            continue
        contents.append(path.read_text(encoding="utf-8"))
    return "\n".join(contents)


def update_documentation() -> None:
    """Placeholder routine for documentation updates."""

    print("Updating documentation repositories ... (not implemented)")


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Merge documentation files")
    parser.add_argument("files", nargs="+", help="Documentation files to merge")
    args = parser.parse_args()

    merged = merge_sources(args.files)
    print(merged)


if __name__ == "__main__":
    _cli()
