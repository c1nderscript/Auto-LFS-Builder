"""Package Analyzer.
Determines package requirements from documentation sources.
"""

from pathlib import Path
from bs4 import BeautifulSoup

from .lfs_parser import resolve_dependencies

ROOT = Path(__file__).resolve().parents[2]
LFS_DOCS = ROOT / "docs" / "lfs-git"

def analyze_package(package_name):
    """Analyze package build instructions"""
    version = None
    pkg_ent = LFS_DOCS / "packages.ent"
    search = f"<!ENTITY {package_name.lower()}-version"
    with pkg_ent.open("r", encoding="utf-8") as f:
        for line in f:
            if line.strip().startswith(search):
                parts = line.split('"')
                if len(parts) >= 2:
                    version = parts[1]
                break

    deps = resolve_dependencies(package_name)
    return {"name": package_name, "version": version, "dependencies": deps}

def extract_requirements(package_name=None):
    """Extract host system package requirements"""
    req_file = LFS_DOCS / "chapter02" / "hostreqs.xml"
    requirements = {}

    with req_file.open("r", encoding="utf-8") as f:
        soup = BeautifulSoup(f, "xml")

    for li in soup.find_all("listitem"):
        emph = li.find("emphasis", {"role": "strong"})
        if not emph:
            continue
        text = emph.get_text().strip()
        if "-" in text:
            name, version = text.split("-", 1)
            requirements[name] = version
        else:
            requirements[text] = None

    if package_name:
        return {package_name: requirements.get(package_name)}

    return requirements

if __name__ == "__main__":
    import sys

    pkg = sys.argv[1] if len(sys.argv) > 1 else "bash"
    info = analyze_package(pkg)
    print(info)

    reqs = extract_requirements()
    print("Host requirements sample:")
    for name, ver in list(reqs.items())[:5]:
        print(f"  {name}: {ver}")
