#!/usr/bin/env python3
"""LFS Documentation Parser.

This module provides utilities to parse the XML/HTML files from the
``docs/lfs-git`` directory and extract the build commands required for
constructing a Linux From Scratch system.

The parser is intentionally minimal at this stage. Functions contain
placeholder implementations that will be expanded as the project grows.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable, List

from bs4 import BeautifulSoup


def extract_commands_from_file(path: Path) -> List[str]:
    """Return a list of build commands from a single LFS XML/HTML file.

    Parameters
    ----------
    path: Path
        The XML or HTML file to process.

    Returns
    -------
    list of str
        Extracted commands in the order they appear in the file.

    Notes
    -----
    This function currently returns an empty list. Future implementations
    will parse ``<userinput>`` sections or other code blocks found in the
    LFS documentation.
    """
    # TODO: implement command extraction logic
    _ = path  # placeholder to satisfy linters
    return []


def parse_build_steps(root: Path) -> Iterable[str]:
    """Walk ``root`` and yield build commands found in documentation files."""
    for file in root.rglob("*.xml"):
        yield from extract_commands_from_file(file)


def main(argv: List[str] | None = None) -> None:
    """Entry point for command-line usage."""
    parser = argparse.ArgumentParser(
        description="Parse LFS documentation and output build steps"
    )
    parser.add_argument(
        "docs_root",
        type=Path,
        default=Path("docs/lfs-git"),
        nargs="?",
        help="Path to the LFS documentation root (default: docs/lfs-git)",
    )
    args = parser.parse_args(argv)

    for cmd in parse_build_steps(args.docs_root):
        print(cmd)


if __name__ == "__main__":
    main()
