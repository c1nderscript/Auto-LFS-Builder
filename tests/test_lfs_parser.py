import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'src'))

from parsers import lfs_parser


def test_extract_build_commands():
    sample = Path('docs/lfs-git/chapter05/binutils-pass1.xml')
    commands = lfs_parser.extract_build_commands(sample)
    assert commands, 'No commands extracted'
    joined = '\n'.join(commands)
    assert 'make' in joined
