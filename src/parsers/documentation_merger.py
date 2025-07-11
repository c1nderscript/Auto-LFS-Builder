"""Documentation Merger.
Combines LFS, BLFS, JHALFS, and GLFS documentation sources.
"""

from __future__ import annotations

import os
import subprocess


def merge_sources(sources: list[str]):
    """Merge multiple documentation sources into a single string.

    Parameters
    ----------
    sources : list[str]
        List of file paths to combine.
    """

    contents = []
    for path in sources:
        if not os.path.exists(path):
            continue
        with open(path, "r", encoding="utf-8") as fh:
            contents.append(fh.read())
    return "\n".join(contents)


def update_documentation(repos: list[str] | None = None):
    """Fetch and update documentation repositories using ``git pull``.

    Parameters
    ----------
    repos: list[str] | None
        Paths to documentation repositories.  Defaults to the standard
        directories under ``docs/``.
    """

    if repos is None:
        repos = [
            os.path.join("docs", "lfs-git"),
            os.path.join("docs", "blfs-git"),
            os.path.join("docs", "jhalfs"),
            os.path.join("docs", "glfs"),
        ]

    for repo in repos:
        if os.path.isdir(repo):
            try:
                subprocess.run(["git", "pull"], cwd=repo, check=False,
                               stdout=subprocess.DEVNULL,
                               stderr=subprocess.DEVNULL)
            except Exception:
                # Ignore errors in offline environments
                pass

if __name__ == "__main__":
    # Placeholder for CLI usage
    pass
