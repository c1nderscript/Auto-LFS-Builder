import os
import sys
import argparse
import xml.etree.ElementTree as ET


def extract_commands_from_file(path: str):
    """Extract command text from <screen> or <pre> tags in a DocBook XML file."""
    commands = []
    try:
        tree = ET.parse(path)
    except ET.ParseError:
        # Skip invalid XML files
        return commands
    root = tree.getroot()
    for tag in root.iter():
        if tag.tag in ("screen", "pre"):
            text = "".join(tag.itertext())
            # Clean up whitespace
            lines = [line.rstrip() for line in text.splitlines()]
            cleaned = "\n".join(line for line in lines if line.strip())
            if cleaned:
                commands.append(cleaned)
    return commands


def extract_commands(source_dir: str):
    """Recursively parse XML files in source_dir and collect commands."""
    commands = []
    for root_dir, _dirs, files in os.walk(source_dir):
        for name in files:
            if name.endswith(".xml"):
                path = os.path.join(root_dir, name)
                commands.extend(extract_commands_from_file(path))
    return commands


def main(argv=None):
    parser = argparse.ArgumentParser(description="Extract build commands from LFS documentation")
    parser.add_argument("source", help="Path to the lfs-git directory")
    parser.add_argument("output", nargs="?", default="generated/lfs_commands.sh",
                        help="Where to write the extracted commands")
    args = parser.parse_args(argv)

    commands = extract_commands(args.source)
    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    with open(args.output, "w") as f:
        f.write("\n\n".join(commands))

    # Also print to stdout for convenience
    for cmd in commands:
        print(cmd)


if __name__ == "__main__":
    main()
