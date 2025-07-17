import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run_script(path, *args, env=None):
    env_dict = os.environ.copy()
    env_dict["CI"] = "true"
    env_dict["BASH_ENV"] = str(ROOT / 'tests' / 'stubs.sh')
    if env:
        env_dict.update(env)
    result = subprocess.run([
        str(ROOT / path), *args
    ], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, cwd=ROOT, env=env_dict)
    assert result.returncode == 0, result.stdout
    return result.stdout


def test_dependency_checker_runs():
    out = run_script('src/validators/dependency_checker.sh')
    assert 'Dependency check complete' in out


def test_package_tester_runs():
    out = run_script('src/validators/package_tester.sh', 'bash')
    assert 'Package testing complete' in out


def test_system_validator_runs():
    out = run_script('src/validators/system_validator.sh', env={'GNOME_ENABLED': 'false'})
    assert 'System validation complete' in out


def test_validation_suite_warns_on_missing_tools():
    out = run_script('generated/validation_suite.sh')
    assert 'essential tools are missing' in out
    assert 'WARNING' in out
