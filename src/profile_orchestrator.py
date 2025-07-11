#!/usr/bin/env python3
"""Profile Orchestrator
Reads build profiles and executes builder scripts in order.
"""

import os
import subprocess
import logging
from pathlib import Path

PROFILE_DIR = Path("config/build_profiles")
GENERATED_DIR = Path("generated")
LOG_DIR = Path("logs/build_logs")
BUILD_SCRIPTS_DEFAULT = [
    "lfs_base_build.sh",
    "networking_setup.sh",
    "x_window_build.sh",
    "gnome_desktop.sh",
    "blfs_extras.sh",
    "system_finalization.sh",
]


def load_profile(name: str) -> dict:
    """Load key=value pairs from a profile file."""
    path = PROFILE_DIR / f"{name}.conf"
    data = {}
    if not path.exists():
        logging.warning("Profile %s not found, using defaults", name)
        return data
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" in line:
            key, val = line.split("=", 1)
            data[key.strip()] = val.strip().strip('"')
    return data


def run_script(script: str, env: dict) -> None:
    """Execute a build script with logging."""
    script_path = GENERATED_DIR / script
    logging.info("Running %s", script_path)
    subprocess.run(["bash", str(script_path)], check=True, env=env)


def main() -> None:
    profile_name = os.environ.get("BUILD_PROFILE", "desktop_gnome")
    profile_data = load_profile(profile_name)

    env = os.environ.copy()
    env.update(profile_data)

    steps = profile_data.get("BUILD_STEPS", "").split()
    if not steps:
        steps = BUILD_SCRIPTS_DEFAULT

    for script in steps:
        run_script(script, env)

    # Run system validation after all steps
    validator = Path("src/validators/system_validator.sh")
    logging.info("Running system validation")
    subprocess.run(["bash", str(validator)], check=True, env=env)


if __name__ == "__main__":
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        filename=LOG_DIR / "orchestrator.log",
        level=logging.INFO,
        format="%(asctime)s %(levelname)s: %(message)s",
    )
    main()
