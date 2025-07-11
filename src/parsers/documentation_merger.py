# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

"""Utilities for combining documentation sources."""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys


def merge_sources(sources: list[str | Path]) -> str:
    """Return the concatenation of all files in *sources*."""

    contents = []
    for src in sources:
        path = Path(src)
        if not path.exists():
            continue
        contents.append(path.read_text(encoding="utf-8"))
    return "\n".join(contents)


def _run_git_pull(repo: Path) -> None:
    """Run ``git pull`` inside *repo* and surface any errors."""

    if not (repo / ".git").exists():
        print(f"{repo} is not a git repository", file=sys.stderr)
        return

    try:
        result = subprocess.run(
            ["git", "-C", str(repo), "pull", "--ff-only"],
            capture_output=True,
            text=True,
            check=True,
        )
    except subprocess.CalledProcessError as exc:
        err = exc.stderr.strip() if exc.stderr else "git pull failed"
        print(f"Error updating {repo.name}: {err}", file=sys.stderr)
        raise RuntimeError(f"Failed to update {repo}") from exc

    if result.stdout:
        print(result.stdout.strip())


def update_documentation() -> None:
    """Update all documentation repositories in ``docs/``."""

    docs_root = Path(__file__).resolve().parents[2] / "docs"
    for name in ("lfs-git", "blfs-git", "jhalfs"):
        _run_git_pull(docs_root / name)


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Merge documentation files")
    parser.add_argument(
        "files",
        nargs="*",
        help="Documentation files to merge",
    )
    parser.add_argument(
        "--update-docs",
        action="store_true",
        help="Update documentation repositories before processing",
    )
    args = parser.parse_args()

    if args.update_docs:
        update_documentation()
        if not args.files:
            return

    if args.files:
        merged = merge_sources(args.files)
        print(merged)


if __name__ == "__main__":
    _cli()
