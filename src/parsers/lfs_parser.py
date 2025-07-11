"""LFS Documentation Parser.
Parses LFS HTML/XML files to extract build commands and dependency information.
"""

from pathlib import Path
from bs4 import BeautifulSoup

ROOT = Path(__file__).resolve().parents[2]
LFS_DOCS = ROOT / "docs" / "lfs-git"


def extract_build_commands(chapter_file):
    """Extract build commands from LFS documentation"""
    path = Path(chapter_file)
    if not path.is_absolute():
        path = LFS_DOCS / path

    with path.open("r", encoding="utf-8") as f:
        soup = BeautifulSoup(f, "xml")

    commands = []
    for userinput in soup.find_all("userinput"):
        text = userinput.get_text().strip()
        if not text:
            continue
        for line in text.splitlines():
            line = line.strip()
            if line:
                commands.append(line)
    return commands


def resolve_dependencies(package_name):
    """Parse dependency information from documentation"""
    dep_file = LFS_DOCS / "appendices" / "dependencies.xml"
    package = package_name.strip().lower()

    with dep_file.open("r", encoding="utf-8") as f:
        soup = BeautifulSoup(f, "xml")

    bridge = None
    for b in soup.find_all("bridgehead"):
        if b.get_text().strip().lower() == package:
            bridge = b
            break

    if not bridge:
        return []

    seg_id = f"{package}-depends"
    seglist = soup.find("segmentedlist", {"id": seg_id})
    if not seglist:
        return []

    dependencies = []
    for seg in seglist.find_all("seg"):
        text = seg.get_text().replace(" and ", ",")
        for dep in text.split(','):
            dep = dep.strip()
            if dep:
                dependencies.append(dep)
    return dependencies


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: lfs_parser.py <chapter-file> [package]")
        sys.exit(0)

    chapter = sys.argv[1]
    commands = extract_build_commands(chapter)
    print(f"Found {len(commands)} build commands in {chapter}")
    for cmd in commands[:5]:
        print(cmd)

    if len(sys.argv) > 2:
        pkg = sys.argv[2]
        deps = resolve_dependencies(pkg)
        print(f"Dependencies for {pkg}: {', '.join(deps) if deps else 'None'}")
