import sys
from pathlib import Path
import subprocess
import pytest

pytest.importorskip("bs4")

ENV = {'PYTHONPATH': str(Path(__file__).resolve().parents[1] / 'src')}


def test_lfs_parser_cli():
    sample = 'docs/lfs-git/chapter05/binutils-pass1.xml'
    result = subprocess.run([
        sys.executable,
        '-m', 'parsers.lfs_parser',
        sample
    ], capture_output=True, text=True, env=ENV)
    assert result.returncode == 0
    assert 'make' in result.stdout


def test_dependency_resolver_cli():
    result = subprocess.run([
        sys.executable,
        '-m', 'parsers.dependency_resolver',
        'Acl'
    ], capture_output=True, text=True, env=ENV)
    assert result.returncode == 0
    assert 'acl' in result.stdout.lower()
