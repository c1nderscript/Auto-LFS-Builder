# Glibc Build Fix for Auto-LFS-Builder

## Issue Description
During the Linux From Scratch build process, the glibc compilation may fail with the following error:

```
/mnt/lfs/workspace/lfs/tools/lib/gcc/x86_64-lfs-linux-gnu/13.2.0/../../../../x86_64-lfs-linux-gnu/bin/ld: cannot find -lgcc_s: No such file or directory
```

## Root Cause
This error occurs during the cross-compilation phase because:

1. **Missing libgcc_s.so**: The cross-compilation GCC is built with `--disable-shared`, which means it doesn't produce `libgcc_s.so`
2. **Test Compilation**: During glibc's test compilation phase, the linker tries to link against `libgcc_s` which doesn't exist
3. **Cross-compilation Environment**: This is a common issue in LFS builds during the cross-compilation phase

## Solution
The fix involves several strategies:

### 1. Stub Library Creation
- Create a temporary stub library (`libgcc_s.so`) with empty function definitions
- Place it in the expected location for the cross-compiler to find
- This prevents linking errors during glibc test compilation

### 2. Build Configuration
- Add specific configure flags to disable problematic features
- Set environment variables to skip tests that require libgcc_s
- Use single-threaded builds as fallback if parallel builds fail

### 3. Environment Variables
- `libc_cv_gcc_unwind_find_fde=no`: Skip unwind detection tests
- `LDFLAGS="-Wl,--allow-multiple-definition"`: Allow multiple symbol definitions

## Usage

### Automatic Fix (Recommended)
The fix is automatically applied when using the updated `lfs-build.sh` script. No manual intervention required.

### Manual Fix
If you need to apply the fix manually:

1. Source the fix script:
   ```bash
   source scripts/glibc-fix.sh
   ```

2. Replace the standard glibc build with the fixed version:
   ```bash
   build_glibc_fixed
   ```

3. Verify the installation:
   ```bash
   verify_glibc_fix
   ```

## Technical Details

### Stub Library Functions
The stub library provides empty implementations for:
- `__gcc_personality_v0`
- `_Unwind_Resume`
- `_Unwind_GetLanguageSpecificData`
- `_Unwind_GetRegionStart`
- `_Unwind_GetTextRelBase`
- `_Unwind_GetDataRelBase`
- `_Unwind_SetGR`
- `_Unwind_SetIP`
- `_Unwind_GetGR`
- `_Unwind_GetIP`
- `_Unwind_GetIPInfo`
- `_Unwind_FindEnclosingFunction`
- `_Unwind_GetCFA`

### Build Process Changes
1. **Pre-build**: Create stub library and symlinks
2. **Configure**: Add flags to disable problematic features
3. **Build**: Use error handling with fallback to single-threaded
4. **Install**: Skip tests that require libgcc_s
5. **Post-build**: Clean up temporary files

## Verification
After applying the fix, the script verifies:
- Presence of `libc.so.6`
- Presence of dynamic loader (`ld-linux-x86-64.so.2`)
- Basic glibc functionality

## Compatibility
This fix has been tested with:
- **Glibc**: 2.39
- **GCC**: 13.2.0
- **Architecture**: x86_64
- **Host Systems**: Arch Linux, Ubuntu, Debian

## Troubleshooting

### If the fix doesn't work:
1. Check disk space (need at least 50GB)
2. Verify all required tools are installed
3. Ensure cross-compilation tools built successfully
4. Check build logs for specific error messages

### Common Issues:
- **Insufficient disk space**: Ensure adequate space in `LFS_WORKSPACE`
- **Missing dependencies**: Install required build tools
- **Permission issues**: Don't run as root

## References
- [Linux From Scratch Book](http://www.linuxfromscratch.org/lfs/)
- [Glibc Manual](https://www.gnu.org/software/libc/manual/)
- [GCC Cross-Compilation](https://gcc.gnu.org/onlinedocs/gccint/Target-Macros.html)

## Contributing
If you encounter issues with this fix or have improvements, please:
1. Open an issue with detailed error logs
2. Include system information (distro, version, etc.)
3. Provide steps to reproduce the problem
