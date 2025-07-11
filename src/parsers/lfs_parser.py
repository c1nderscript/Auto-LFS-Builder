# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

"""Utilities for parsing LFS documentation files."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

try:
    from bs4 import BeautifulSoup  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    BeautifulSoup = None

DOCS_ROOT = Path(__file__).resolve().parents[2] / "docs"
DEPENDENCY_XML = DOCS_ROOT / "lfs-git" / "appendices" / "dependencies.xml"


def clean_command(text: str) -> str:
    """Remove prompts and extraneous whitespace from a command string."""

    lines = []
    for line in text.strip().splitlines():
        line = line.strip()
        # remove common shell prompts
        line = re.sub(r"^[#$]\s*", "", line)
        lines.append(line)
    return "\n".join(lines)


def is_build_command(cmd: str) -> bool:
    """Return ``True`` if *cmd* looks like an actual build command."""

    return bool(cmd and not cmd.startswith("#"))


def extract_build_commands(chapter_file: str | Path) -> list[str]:
    """Extract build commands from an LFS chapter file."""

    chapter_path = Path(chapter_file)
    text = chapter_path.read_text(encoding="utf-8")

    commands: list[str] = []

    if BeautifulSoup:
        soup = BeautifulSoup(text, "html.parser")
        build_blocks = soup.find_all("pre", class_="userinput")
        build_blocks += soup.find_all("userinput")
        for block in build_blocks:
            cmd = clean_command(block.get_text())
            if is_build_command(cmd):
                commands.append(cmd)
    else:
        for m in re.findall(r"<pre[^>]*class=['\"]userinput['\"][^>]*>(.*?)</pre>", text, flags=re.DOTALL|re.IGNORECASE):
            cmd = clean_command(m)
            if is_build_command(cmd):
                commands.append(cmd)
        for m in re.findall(r"<userinput[^>]*>(.*?)</userinput>", text, flags=re.DOTALL|re.IGNORECASE):
            cmd = clean_command(m)
            if is_build_command(cmd):
                commands.append(cmd)

    return commands


def resolve_dependencies(package_name: str, dependency_file: str | Path = DEPENDENCY_XML) -> list[str]:
    """Parse dependency information for *package_name* from ``dependencies.xml``."""

    dep_path = Path(dependency_file)
    if not dep_path.exists():
        return []

    text = dep_path.read_text(encoding="utf-8")

    if BeautifulSoup:
        soup = BeautifulSoup(text, "xml")

        bridge = None
        for b in soup.find_all("bridgehead"):
            if b.get_text().strip().lower() == package_name.lower():
                bridge = b
                break

        if not bridge:
            return []

        seglist = bridge.find_next("segmentedlist", id=re.compile(r".*-depends$"))
        if not seglist:
            return []

        seg = seglist.find("seg")
        if not seg:
            return []

        text = seg.get_text()
    else:
        m = re.search(
            rf"<bridgehead[^>]*>\s*{re.escape(package_name)}\s*</bridgehead>.*?"
            rf"<segmentedlist[^>]*id=[\"']{package_name.lower()}-depends[\"'][^>]*>"
            r".*?<seg>(.*?)</seg>",
            text,
            flags=re.DOTALL | re.IGNORECASE,
        )
        if not m:
            return []

        text = m.group(1)

    text = re.sub(r"\s+and\s+", ", ", text)
    deps = [d.strip().rstrip(".") for d in text.split(",") if d.strip() and d.strip().lower() != "none"]

    return deps


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Extract build commands from an LFS chapter file")
    parser.add_argument("chapter", help="Path to chapter XML/HTML file")
    args = parser.parse_args()

    commands = extract_build_commands(args.chapter)
    for cmd in commands:
        print(cmd)


if __name__ == "__main__":
    _cli()
