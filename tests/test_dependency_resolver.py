from src.parsers import dependency_resolver


def test_topological_sort_simple():
    graph = {'pkg1': ['pkg2'], 'pkg2': []}
    order = dependency_resolver.topological_sort(graph)
    assert order == ['pkg2', 'pkg1']
