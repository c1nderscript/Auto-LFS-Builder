# Auto-LFS-Builder

Auto-LFS-Builder parses the documentation under `docs/` and produces
scripts that build a complete Linux From Scratch system. The project
aims to generate a fully automated installer with networking and a
GNOME desktop while maintaining detailed logs and validation steps.

## Major components

- **docs/** – LFS, BLFS, JHALFS and GLFS manuals used for automation.
- **src/** – parsers and build helpers that create shell scripts.
- **generated/** – output directory for the final scripts such as
  `complete_build.sh`.
- **tests/** – unit tests and the validation suite.

See [SETUP.md](SETUP.md) for environment variables and configuration
options.

## Running the builder

Configure your environment as described in `SETUP.md` and then invoke:

```bash
bash generated/complete_build.sh
```

This command launches the full build process and creates a self-installing system.

## Running tests

To verify the generated scripts you can run the validation suite and
unit tests:

```bash
bash generated/validation_suite.sh
bash tests/run_tests.sh
```

These are the same commands executed by the CI workflow.
