"""Helpers for analyzing package build instructions."""

from __future__ import annotations

import argparse
import os
from pathlib import Path

from .lfs_parser import extract_build_commands, resolve_dependencies

DOCS_ROOT = Path(__file__).resolve().parents[2] / "docs"


def _find_package_file(package_name: str, root: Path = DOCS_ROOT) -> Path | None:
    name_lower = package_name.lower()
    for directory, _, files in os.walk(root):
        for f in files:
            if f.lower().startswith(name_lower) and f.endswith(".xml"):
                return Path(directory) / f
    return None


def analyze_package(package_name: str) -> dict:
    """Return build commands and dependencies for *package_name*."""

    path = _find_package_file(package_name)
    if not path:
        return {}

    commands = extract_build_commands(path)
    deps = resolve_dependencies(package_name)
    return {"name": package_name, "file": str(path), "commands": commands, "dependencies": deps}


def extract_requirements(package_name: str) -> list[str]:
    """Extract dependency requirements for *package_name*."""

    return resolve_dependencies(package_name)


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Analyze a package definition")
    parser.add_argument("package", help="Package name")
    args = parser.parse_args()

    data = analyze_package(args.package)
    if not data:
        print("Package not found")
        return

    print(f"Package: {data['name']}")
    print(f"File: {data['file']}")
    print("Dependencies:")
    for dep in data["dependencies"]:
        print(f"  - {dep}")
    print("Commands:")
    for cmd in data["commands"]:
        print(cmd)


if __name__ == "__main__":
    _cli()
