# Auto-LFS-Builder

An automated linux from scratch builder.

This script builds:

Linux from Scratch

Beyond Linux from Scratch

Gaming on Linux from Scratch

All in one application.

## Environment Validation

A helper script `scripts/validate_environment.sh` checks that your system has all
required tools and enough resources before starting a build.

Run it with:

```bash
./scripts/validate_environment.sh        # run both checks
./scripts/validate_environment.sh validate  # only tool check
./scripts/validate_environment.sh health    # only environment health check
```
