import pytest
from src.parsers.lfs_parser import resolve_dependencies, XMLParseError, parse_xml

def test_dependency_detection():
    """Test dependency detection for bash and coreutils packages"""
    
    # Test bash dependencies
    expected_bash_deps = [
        'Acl',
        'Attr',
        'Glibc',
        'Grep',
        'Ncurses',
        'Readline',
        'Sh-utils'
    ]
    
    # Test coreutils dependencies
    expected_coreutils_deps = [
        'Acl',
        'Attr',
        'Glibc',
        'GMP',
        'Libcap'
    ]
    
    # Test dependency resolution
    assert sorted(resolve_dependencies('bash')) == sorted(expected_bash_deps)
    assert sorted(resolve_dependencies('coreutils')) == sorted(expected_coreutils_deps)

def test_invalid_package():
    """Test handling of non-existent package"""
    assert resolve_dependencies('nonexistent_package') == []

def test_xml_parse_error():
    """Test XML parsing error handling"""
    with pytest.raises(XMLParseError):
        parse_xml("invalid xml content")

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'src'))

from parsers import package_analyzer


def test_analyze_bash():
    data = package_analyzer.analyze_package('bash')
    assert data, 'analyze_package returned empty data'
    assert data['commands'], 'commands list is empty'
    assert 'Glibc' in data['dependencies']


def test_analyze_coreutils():
    data = package_analyzer.analyze_package('coreutils')
    assert data['commands'], 'commands list is empty for coreutils'
    assert 'Patch' in data['dependencies']
