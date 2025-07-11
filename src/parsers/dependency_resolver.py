"""Build Dependency Resolver.
Calculates build order for packages based on parsed documentation.
"""

from __future__ import annotations

from collections import defaultdict, deque


def build_dependency_graph(packages: dict[str, list[str]]):
    """Create a dependency graph from given package list.

    Parameters
    ----------
    packages : dict
        Mapping of package name to a list of its dependencies.

    Returns
    -------
    dict[str, set[str]]
        Normalised dependency graph including standalone nodes for
        packages appearing only as dependencies.
    """

    graph: dict[str, set[str]] = defaultdict(set)
    for pkg, deps in packages.items():
        graph[pkg].update(deps)
        for dep in deps:
            graph.setdefault(dep, set())
    return graph


def topological_sort(graph: dict[str, set[str]]):
    """Perform topological sort on dependency graph.

    Parameters
    ----------
    graph: dict[str, set[str]]
        Graph as returned by :func:`build_dependency_graph`.

    Returns
    -------
    list[str]
        Packages sorted in dependency order.  Raises ``ValueError`` if a
        cycle is detected.
    """

    indegree: dict[str, int] = {node: 0 for node in graph}
    for deps in graph.values():
        for dep in deps:
            indegree[dep] = indegree.get(dep, 0) + 1

    queue = deque([n for n, d in indegree.items() if d == 0])
    order = []

    while queue:
        node = queue.popleft()
        order.append(node)
        for dep in graph.get(node, []):
            indegree[dep] -= 1
            if indegree[dep] == 0:
                queue.append(dep)

    if len(order) != len(graph):
        raise ValueError("Dependency cycle detected")

    # Reverse the resulting order so that dependencies appear before
    # the packages that require them.
    return order[::-1]


if __name__ == "__main__":
    # Placeholder for CLI usage
    pass
