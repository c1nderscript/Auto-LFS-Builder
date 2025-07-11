"""Build Dependency Resolver.
Calculates build order for packages based on parsed documentation.
"""


def build_dependency_graph(packages):
    """Create a dependency graph from given package list.

    Parameters
    ----------
    packages : dict
        Mapping of package name to iterable of dependency names.
    """
    graph = {}
    for pkg, deps in packages.items():
        graph.setdefault(pkg, set())
        for dep in deps:
            graph[pkg].add(dep)
            graph.setdefault(dep, set())
    return graph


def topological_sort(graph):
    """Perform topological sort on dependency graph.

    Raises
    ------
    ValueError
        If a dependency cycle is detected.
    """
    in_degree = {node: 0 for node in graph}
    for node, deps in graph.items():
        for dep in deps:
            in_degree[dep] = in_degree.get(dep, 0) + 1

    order = []
    queue = [n for n, d in in_degree.items() if d == 0]
    while queue:
        node = queue.pop(0)
        order.append(node)
        for dep in graph.get(node, []):
            in_degree[dep] -= 1
            if in_degree[dep] == 0:
                queue.append(dep)

    if len(order) != len(in_degree):
        raise ValueError("Dependency cycle detected")

    return order


if __name__ == "__main__":
    sample = {
        "gcc": ["glibc", "zlib"],
        "glibc": ["zlib"],
        "bash": ["glibc"],
        "zlib": [],
    }

    graph = build_dependency_graph(sample)
    order = topological_sort(graph)
    print("Build order:", order)
