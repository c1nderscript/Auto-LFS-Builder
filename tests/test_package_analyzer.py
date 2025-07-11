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
