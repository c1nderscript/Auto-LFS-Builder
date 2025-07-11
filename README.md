# Auto-LFS-Builder

Auto-LFS-Builder aims to automate the entire Linux From Scratch build process. It reads documentation from the `docs/` directory and generates shell scripts that create a complete system with optional desktop and networking support.

## Environment configuration

All environment variables and configuration options are defined in [`setup.sh`](setup.sh). Review that file and export the variables appropriate for your environment before running any build commands.

```bash
source ./setup.sh
```

## Preparing documentation

Place the current LFS, BLFS, JHALFS and related manuals inside the `docs/` directory. The automation tools rely on these sources when generating the build scripts. If you update the documentation, rerun the parsing utilities to regenerate the scripts.

## Running the build scripts

Once implemented, generated scripts will appear in the `generated/` directory. With your environment configured, start the build with:

```bash
bash generated/complete_build.sh
```

This will build the system according to the chosen configuration.
