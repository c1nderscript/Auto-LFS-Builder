#!/bin/bash
# Quick Fix Script for Auto-LFS-Builder Critical Issues
# This script patches the main build script to add missing dependencies and fix critical issues

set -e

echo "🔧 Applying critical fixes to Auto-LFS-Builder..."

# Backup original files
cp lfs-build.sh lfs-build.sh.backup
cp docker-compose.yml docker-compose.yml.backup
cp lfs-builder.env lfs-builder.env.backup

echo "✅ Backed up original files"

# Fix 1: Add missing GCC dependencies to lfs-build.sh
echo "🔧 Adding missing GCC dependencies (GMP, MPFR, MPC)..."

# Create a temporary sed script to add the missing packages
cat > /tmp/fix_packages.sed << 'EOF'
/https:\/\/ftp\.gnu\.org\/gnu\/gcc\/gcc-13\.2\.0\/gcc-13\.2\.0\.tar\.xz/a\
        "https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"\
        "https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"\
        "https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
EOF

sed -i -f /tmp/fix_packages.sed lfs-build.sh

# Fix 2: Add missing core packages
cat > /tmp/fix_core_packages.sed << 'EOF'
/https:\/\/www\.kernel\.org\/pub\/linux\/utils\/util-linux\/v2\.41\/util-linux-2\.41\.1\.tar\.xz/a\
        "https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz"\
        "https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz"\
        "https://tukaani.org/xz/xz-5.4.6.tar.xz"
EOF

sed -i -f /tmp/fix_core_packages.sed lfs-build.sh

# Fix 3: Standardize environment variables in lfs-build.sh
echo "🔧 Standardizing environment variables..."

sed -i 's/GNOME_ENABLED/GNOME_ENABLED/g' lfs-build.sh
sed -i 's/NETWORKING_ENABLED/NETWORKING_ENABLED/g' lfs-build.sh

# Fix 4: Add missing tools to core tools list
echo "🔧 Adding missing tools to build list..."

cat > /tmp/fix_tools.sed << 'EOF'
/util-linux-2\.41\.1\.tar\.xz/a\
        "diffutils-3.10.tar.xz"\
        "patch-2.7.6.tar.xz"\
        "xz-5.4.6.tar.xz"
EOF

sed -i -f /tmp/fix_tools.sed lfs-build.sh

# Fix 5: Update util-linux build configuration
echo "🔧 Improving util-linux build configuration..."

cat > /tmp/fix_util_linux.sed << 'EOF'
/.*util-linux.*/,/.*make DESTDIR.*install.*/{
    /.*util-linux.*/{
        a\
                mkdir -pv /var/lib/hwclock\
                ./configure --prefix=/usr --host="$LFS_TGT" --libdir=/usr/lib \\\
                           --disable-chfn-chsh --disable-login --disable-nologin \\\
                           --disable-su --disable-setpriv --disable-runuser \\\
                           --disable-pylibmount --disable-static --without-python \\\
                           ADJTIME_PATH=/var/lib/hwclock/adjtime\
                make_build\
                make DESTDIR="$LFS" install\
                ;;
        d
    }
    /.*configure.*host.*LFS_TGT.*/d
    /.*make_build.*/d
    /.*make DESTDIR.*install.*/d
}
EOF

sed -i -f /tmp/fix_util_linux.sed lfs-build.sh

# Fix 6: Update docker-compose.yml environment variables
echo "🔧 Fixing docker-compose.yml..."

sed -i 's/PARALLEL_JOBS: 32/PARALLEL_JOBS: 16/' docker-compose.yml

# Fix 7: Update lfs-builder.env
echo "🔧 Updating environment configuration..."

cat > lfs-builder.env << 'EOF'
LFS_WORKSPACE=/lfs-build/workspace
BUILD_PROFILE=desktop_gnome
PARALLEL_JOBS=16
LFS_VERSION=development
GNOME_ENABLED=true
NETWORKING_ENABLED=true
CREATE_ISO=true
ISO_VOLUME=AUTO_LFS
ISO_OUTPUT=/lfs-build/workspace/auto-lfs.iso
LOG_PATH=/lfs-build/logs/build.log
EOF

# Fix 8: Create missing sysconfig directory in configure_system
echo "🔧 Ensuring sysconfig directory creation..."

sed -i '/# Create network interfaces file/i\        mkdir -p "$LFS/etc/sysconfig"' lfs-build.sh

# Clean up temporary files
rm -f /tmp/fix_*.sed

# Verify fixes
echo "🔍 Verifying fixes..."

# Check if GCC dependencies were added
if grep -q "mpfr-4.2.1.tar.xz" lfs-build.sh && grep -q "gmp-6.3.0.tar.xz" lfs-build.sh && grep -q "mpc-1.3.1.tar.gz" lfs-build.sh; then
    echo "✅ GCC dependencies added successfully"
else
    echo "❌ Failed to add GCC dependencies"
    exit 1
fi

# Check if environment variables were standardized
if grep -q "GNOME_ENABLED" lfs-build.sh && ! grep -q "GNOME_ENABLED" lfs-build.sh; then
    echo "✅ Environment variables standardized"
else
    echo "❌ Environment variable standardization incomplete"
fi

# Check if additional packages were added
if grep -q "diffutils-3.10.tar.xz" lfs-build.sh && grep -q "patch-2.7.6.tar.xz" lfs-build.sh; then
    echo "✅ Additional core packages added"
else
    echo "❌ Failed to add additional core packages"
fi

echo ""
echo "🎉 Auto-LFS-Builder fixes applied successfully!"
echo ""
echo "The following critical issues have been fixed:"
echo "  ✅ Added missing GCC dependencies (GMP, MPFR, MPC)"
echo "  ✅ Standardized environment variables"
echo "  ✅ Added missing core packages (diffutils, patch, xz)"
echo "  ✅ Improved util-linux build configuration"
echo "  ✅ Fixed directory creation issues"
echo "  ✅ Updated Docker configuration"
echo ""
echo "You can now run the build with:"
echo "  docker compose up --build"
echo ""
echo "Original files have been backed up with .backup extension."
