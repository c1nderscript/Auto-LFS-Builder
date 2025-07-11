import sys
from pathlib import Path

import pytest

# skip if BeautifulSoup is unavailable
pytest.importorskip("bs4")

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'src'))

from parsers import dependency_resolver


def test_topological_sort_simple():
    graph = {'pkg1': ['pkg2'], 'pkg2': []}
    order = dependency_resolver.topological_sort(graph)
    assert order == ['pkg2', 'pkg1']
