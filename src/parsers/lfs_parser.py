"""LFS Documentation Parser.
Parses LFS HTML/XML files to extract build commands and dependency information.
"""

from __future__ import annotations

import os
import re
import xml.etree.ElementTree as ET

try:  # BeautifulSoup is optional in this environment
    from bs4 import BeautifulSoup
except Exception:  # pragma: no cover - fallback when bs4 is missing
    BeautifulSoup = None  # type: ignore


def _parse_with_soup(data: str):
    soup = BeautifulSoup(data, "html.parser")
    commands = []
    for node in soup.find_all("userinput"):
        text = node.get_text()
        if text:
            commands.append(text.strip())
    return commands


def _parse_with_etree(data: str):
    root = ET.fromstring(data)
    commands = []
    for elem in root.findall(".//userinput"):
        if elem.text:
            commands.append(elem.text.strip())
    return commands


def extract_build_commands(chapter_file: str):
    """Extract build commands from LFS documentation.

    The function looks for ``userinput`` elements inside ``screen`` blocks
    which typically contain build instructions in the LFS book.
    """

    with open(chapter_file, "r", encoding="utf-8") as fh:
        data = fh.read()

    if BeautifulSoup is not None:
        return _parse_with_soup(data)
    return _parse_with_etree(data)


def resolve_dependencies(package_name: str, dep_file: str = None):
    """Parse dependency information from documentation.

    Parameters
    ----------
    package_name: str
        Name of the package to resolve.
    dep_file: str, optional
        Path to the ``dependencies.xml`` file.  If omitted, the function
        looks for it under ``docs/lfs-git/appendices/dependencies.xml``.
    """

    if dep_file is None:
        dep_file = os.path.join(
            os.path.dirname(os.path.dirname(__file__)),
            "..",
            "docs",
            "lfs-git",
            "appendices",
            "dependencies.xml",
        )

    if not os.path.exists(dep_file):
        return []

    with open(dep_file, "r", encoding="utf-8") as fh:
        data = fh.read()

    if BeautifulSoup is not None:
        soup = BeautifulSoup(data, "html.parser")
        target = soup.find("segmentedlist", id=f"{package_name.lower()}-depends")
        if not target:
            return []
        text = " ".join(seg.get_text() for seg in target.find_all("seg"))
    else:
        root = ET.fromstring(data)
        target = root.find(f".//segmentedlist[@id='{package_name.lower()}-depends']")
        if target is None:
            return []
        text = " ".join(seg.text or "" for seg in target.findall(".//seg"))

    # Split dependencies by comma or 'and'
    parts = re.split(r",|and", text)
    deps = [p.strip() for p in parts if p.strip()]
    return deps


if __name__ == "__main__":
    # Placeholder for CLI usage
    pass
