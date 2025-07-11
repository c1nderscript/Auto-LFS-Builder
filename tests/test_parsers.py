import os
import sys
from pathlib import Path

# Ensure package imports resolve properly
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from src.parsers import lfs_parser, dependency_resolver, documentation_merger, package_analyzer

def test_extract_build_commands(tmp_path):
    xml_content = """
    <sect1>
      <screen><userinput>make</userinput></screen>
      <screen><userinput>make install</userinput></screen>
    </sect1>
    """
    xml_file = tmp_path / "sample.xml"
    xml_file.write_text(xml_content)
    cmds = lfs_parser.extract_build_commands(str(xml_file))
    assert cmds == ["make", "make install"]


def test_topological_sort():
    packages = {"A": ["B"], "B": ["C"], "C": []}
    graph = dependency_resolver.build_dependency_graph(packages)
    order = dependency_resolver.topological_sort(graph)
    assert order.index("C") < order.index("B") < order.index("A")


def test_merge_sources(tmp_path):
    f1 = tmp_path / "a.txt"
    f2 = tmp_path / "b.txt"
    f1.write_text("first")
    f2.write_text("second")
    merged = documentation_merger.merge_sources([str(f1), str(f2)])
    assert "first" in merged and "second" in merged
