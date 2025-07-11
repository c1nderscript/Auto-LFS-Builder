"""Documentation Merger.
Combines LFS, BLFS, JHALFS, and GLFS documentation sources.
"""

from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / "docs"

def merge_sources(sources):
    """Merge multiple documentation sources"""
    texts = []
    for src in sources:
        path = Path(src)
        if not path.is_absolute():
            path = DOCS / path
        if path.is_file():
            texts.append(path.read_text(encoding="utf-8"))
    return "\n".join(texts)

def update_documentation():
    """Fetch and update documentation repositories"""
    repos = ["lfs-git", "blfs-git", "jhalfs", "glfs"]
    for repo in repos:
        repo_path = DOCS / repo
        if repo_path.is_dir() and (repo_path / ".git").exists():
            subprocess.run([
                "git",
                "-C",
                str(repo_path),
                "pull",
                "origin",
                "master",
            ])

if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "update":
        update_documentation()
    else:
        sample = ["lfs-git/README", "jhalfs/README"]
        merged = merge_sources(sample)
        print(merged[:200])
