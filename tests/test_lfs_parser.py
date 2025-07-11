from pathlib import Path

from src.parsers import lfs_parser


def test_extract_build_commands():
    sample = Path('docs/lfs-git/chapter05/binutils-pass1.xml')
    commands = lfs_parser.extract_build_commands(sample)
    assert commands, 'No commands extracted'
    joined = '\n'.join(commands)
    assert 'make' in joined
