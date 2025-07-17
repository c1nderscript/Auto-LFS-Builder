import subprocess
from pathlib import Path
import textwrap


def test_mock_jhalfs_run(tmp_path: Path) -> None:
    """Run a mocked jhalfs script and verify generated files."""
    script = tmp_path / "jhalfs"
    script.write_text(
        textwrap.dedent(
            """
            #!/bin/bash
            set -e
            outdir=$1
            mkdir -p "$outdir/scripts"
            touch "$outdir/scripts/Makefile"
            echo "Mock jhalfs completed"
            """
        )
    )
    script.chmod(0o755)

    workdir = tmp_path / "work"
    result = subprocess.run(
        [str(script), str(workdir)],
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0
    assert "Mock jhalfs completed" in result.stdout
    assert (workdir / "scripts" / "Makefile").is_file()
