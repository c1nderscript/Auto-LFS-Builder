"""Package Analyzer.
Determines package requirements from documentation sources.
"""

from __future__ import annotations

import os

from . import lfs_parser


def _find_package_file(package_name: str, docs_root: str) -> str | None:
    """Search for an XML file describing ``package_name`` within ``docs_root``."""

    target = f"{package_name.lower()}.xml"
    for root, _, files in os.walk(docs_root):
        for f in files:
            if f.lower() == target:
                return os.path.join(root, f)
    return None


def analyze_package(package_name: str, docs_root: str | None = None):
    """Analyze package build instructions.

    Parameters
    ----------
    package_name : str
        Name of the package to search for.
    docs_root : str, optional
        Root directory containing the LFS documentation.  Defaults to
        ``docs/lfs-git``.
    """

    if docs_root is None:
        docs_root = os.path.join("docs", "lfs-git")

    xml_path = _find_package_file(package_name, docs_root)
    if not xml_path:
        return {}

    commands = lfs_parser.extract_build_commands(xml_path)
    deps = lfs_parser.resolve_dependencies(package_name)
    return {"name": package_name, "commands": commands, "dependencies": deps}


def extract_requirements(package_name: str, docs_root: str | None = None):
    """Extract package requirements using :func:`lfs_parser.resolve_dependencies`."""

    return lfs_parser.resolve_dependencies(package_name)

if __name__ == "__main__":
    # Placeholder for CLI usage
    pass
