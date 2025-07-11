import re
from pathlib import Path
from typing import List


def extract_command_blocks(xml_path: str) -> List[str]:
    """Return a list of command blocks from a LFS XML chapter."""
    text = Path(xml_path).read_text(encoding="utf-8")
    blocks = re.findall(r'<screen[^>]*>(.*?)</screen>', text, flags=re.S)
    commands = []
    for block in blocks:
        clean = re.sub(r'<.*?>', '', block, flags=re.S)
        clean = clean.replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&')
        commands.append(clean.strip())
    return commands


if __name__ == "__main__":
    import sys, json
    if len(sys.argv) < 2:
        print("Usage: python lfs_parser.py <chapter.xml>")
        sys.exit(1)
    cmds = extract_command_blocks(sys.argv[1])
    print(json.dumps(cmds, indent=2))
