import sys
from pathlib import Path
import subprocess
import pytest

pytest.importorskip("bs4")

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'src'))

from parsers import package_analyzer


def test_analyze_package_binutils():
    data = package_analyzer.analyze_package('Binutils')
    assert data['name'] == 'Binutils'
    assert data['commands'], 'No commands found'
    assert isinstance(data['dependencies'], list)


def test_package_analyzer_cli():
    env = {'PYTHONPATH': str(Path(__file__).resolve().parents[1] / 'src')}
    result = subprocess.run([
        sys.executable,
        '-m', 'parsers.package_analyzer',
        'Binutils'
    ], capture_output=True, text=True, env=env)
    assert result.returncode == 0
    assert 'Package: Binutils' in result.stdout
