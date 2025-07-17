import subprocess
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run_script(script, *args):
    env = {**dict(os.environ), "CI": "true"}
    proc = subprocess.run([str(ROOT / script), *args], capture_output=True, text=True, env=env)
    assert proc.returncode == 0, proc.stdout + proc.stderr
    return proc.stdout


def test_dependency_checker():
    out = run_script('src/validators/dependency_checker.sh')
    assert 'Dependency check complete' in out


def test_package_tester():
    out = run_script('src/validators/package_tester.sh', 'bash')
    assert 'Package testing complete' in out


def test_system_validator():
    out = run_script('src/validators/system_validator.sh')
    assert 'System validation complete' in out
