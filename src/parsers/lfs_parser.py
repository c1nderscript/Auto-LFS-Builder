from __future__ import annotations

from lxml import etree
from typing import Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class XMLParseError(Exception):
    """Custom exception for XML parsing errors"""
    pass

def parse_xml(content: str) -> Dict[str, Any]:
    """
    Parse XML content using lxml with robust error handling.
    
    Args:
        content: String containing XML data
        
    Returns:
        Dict containing parsed XML data
        
    Raises:
        XMLParseError: If there are issues parsing the XML content
    """
    try:
        # Create a parser with error recovery enabled
        parser = etree.XMLParser(recover=True)
        
        # Parse the XML content
        tree = etree.fromstring(content.encode('utf-8'), parser=parser)
        
        # Check for parser errors
        if len(parser.error_log) > 0:
            for error in parser.error_log:
                logger.warning(f"XML parse warning: {error.message}")
        
        # Convert the XML tree to a dictionary structure
        result = {}
        
        # Process the XML tree
        for element in tree.iter():
            # Strip namespace if present
            tag = element.tag.split('}')[-1] if '}' in element.tag else element.tag
            
            # Get text content, stripping whitespace
            text = element.text.strip() if element.text else ""
            
            # Store attributes and text content
            if element.attrib or text:
                result[tag] = {
                    'attributes': dict(element.attrib),
                    'text': text
                }
        
        return result
        
    except etree.XMLSyntaxError as e:
        error_msg = f"Failed to parse XML: {str(e)}"
        logger.error(error_msg)
        raise XMLParseError(error_msg)
        
    except Exception as e:
        error_msg = f"Unexpected error parsing XML: {str(e)}"
        logger.error(error_msg)
        raise XMLParseError(error_msg)

# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

"""Utilities for parsing LFS documentation files."""

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
