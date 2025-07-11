"""Simple dependency resolution helpers."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from bs4 import BeautifulSoup

DOCS_ROOT = Path(__file__).resolve().parents[2] / "docs"
DEPENDENCY_XML = DOCS_ROOT / "lfs-git" / "appendices" / "dependencies.xml"


def build_dependency_graph(packages: list[str], dependency_file: str | Path = DEPENDENCY_XML) -> dict[str, list[str]]:
    """Create a dependency graph from ``dependencies.xml`` for *packages*."""

    dep_path = Path(dependency_file)
    graph: dict[str, list[str]] = {pkg: [] for pkg in packages}
    if not dep_path.exists():
        return graph

    with dep_path.open(encoding="utf-8") as fh:
        soup = BeautifulSoup(fh, "xml")

    for pkg in packages:
        bridge = None
        for b in soup.find_all("bridgehead"):
            if b.get_text().strip().lower() == pkg.lower():
                bridge = b
                break

        if not bridge:
            continue

        seglist = bridge.find_next("segmentedlist", id=re.compile(r".*-depends$"))
        if not seglist:
            continue

        seg = seglist.find("seg")
        if not seg:
            continue

        text = seg.get_text().replace(" and ", ", ")
        deps = [d.strip().rstrip(".") for d in text.split(",") if d.strip() and d.strip().lower() != "none"]
        graph[pkg] = deps

    return graph


def topological_sort(graph: dict[str, list[str]]) -> list[str]:
    """Perform a topological sort of *graph* returning the build order."""

    order: list[str] = []
    visited: dict[str, str] = {}

    def visit(node: str) -> None:
        state = visited.get(node)
        if state == "visiting":
            raise ValueError(f"circular dependency detected at {node}")
        if state == "visited":
            return
        visited[node] = "visiting"
        for dep in graph.get(node, []):
            if dep in graph:
                visit(dep)
        visited[node] = "visited"
        order.append(node)

    for node in graph:
        visit(node)

    return order


def _cli() -> None:
    parser = argparse.ArgumentParser(description="Resolve package dependencies")
    parser.add_argument("packages", nargs="+", help="Package names to resolve")
    args = parser.parse_args()

    graph = build_dependency_graph(args.packages)
    order = topological_sort(graph)
    for pkg in order:
        print(pkg)


if __name__ == "__main__":
    _cli()
