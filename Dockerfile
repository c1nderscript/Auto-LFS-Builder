FROM archlinux:latest

# Set build arguments for better build caching
ARG BUILDKIT_STEP_LOG_MAX_SIZE=10485760
ARG PARALLEL_JOBS=16
ARG CCACHE_SIZE=10G

# Set environment variables early for better layer caching
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-256color \
    LC_ALL=POSIX \
    LANG=POSIX \
    TZ=UTC

# Update system and install base packages first (better caching)
RUN pacman -Syu --noconfirm --needed

# Install essential system packages
RUN pacman -S --noconfirm --needed \
    base-devel \
    git \
    wget \
    curl \
    nano \
    vim \
    sudo \
    which \
    time \
    strace \
    ltrace \
    lsof \
    procps-ng \
    psmisc \
    util-linux \
    coreutils \
    findutils \
    diffutils \
    gawk \
    sed \
    grep \
    tar \
    gzip \
    bzip2 \
    xz \
    unzip \
    rsync \
    tree \
    htop \
    ncdu

# Install LFS-specific build dependencies
RUN pacman -S --noconfirm --needed \
    m4 \
    texinfo \
    bison \
    flex \
    bc \
    cpio \
    dosfstools \
    parted \
    pkgconf \
    autoconf \
    automake \
    libtool \
    patch \
    python \
    python-pip \
    python-setuptools \
    python-wheel

# Install additional tools for LFS build
RUN pacman -S --noconfirm --needed \
    qemu-system-x86 \
    libisoburn \
    squashfs-tools \
    inotify-tools \
    ccache \
    fakeroot \
    file \
    binutils \
    glibc \
    gcc \
    make \
    kernel-headers-musl

# Install development and debugging tools
RUN pacman -S --noconfirm --needed \
    gdb \
    valgrind \
    perf \
    strace

# Clean package cache to reduce image size
RUN pacman -Scc --noconfirm

# Create lfs-builder user with proper permissions
RUN useradd -m -s /bin/bash -u 1000 -G wheel lfs-builder && \
    echo "lfs-builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/lfs-builder/.cache && \
    chown -R lfs-builder:lfs-builder /home/lfs-builder

# Setup working directories with proper permissions
WORKDIR /lfs-build
RUN mkdir -p /mnt/lfs /lfs-build/workspace /lfs-build/output /lfs-build/logs /lfs-build/cache && \
    chown -R lfs-builder:lfs-builder /mnt/lfs /lfs-build

# Set up ccache with proper configuration
RUN mkdir -p /usr/lib/ccache/bin /var/cache/ccache && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/gcc && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/g++ && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/cc && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/c++ && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/clang && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/clang++ && \
    chown -R lfs-builder:lfs-builder /var/cache/ccache && \
    chmod 755 /usr/lib/ccache/bin/*

# Copy source files with proper ownership
COPY --chown=lfs-builder:lfs-builder . .

# Create comprehensive environment setup
ENV HOME=/home/lfs-builder \
    LFS=/mnt/lfs \
    LFS_WORKSPACE=/lfs-build/workspace \
    BUILD_PROFILE=desktop_gnome \
    PARALLEL_JOBS=${PARALLEL_JOBS} \
    MAKEFLAGS="-j${PARALLEL_JOBS} -l${PARALLEL_JOBS}" \
    GNOME_ENABLED=true \
    NETWORKING_ENABLED=true \
    CREATE_ISO=true \
    VERIFY_PACKAGES=true \
    CCACHE_ENABLED=true \
    CCACHE_SIZE=${CCACHE_SIZE} \
    CCACHE_DIR=/var/cache/ccache \
    CCACHE_COMPILERCHECK=content \
    CCACHE_SLOPPINESS=file_macro,locale,time_macros \
    VERBOSE=true \
    DEBUG=1 \
    V=1 \
    LOG_LEVEL=INFO \
    LOG_PATH=/lfs-build/logs/build.log \
    CONFIG_SHELL=/bin/bash \
    SHELL=/bin/bash \
    PATH=/usr/lib/ccache/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin \
    PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/share/pkgconfig \
    TMPDIR=/tmp \
    BUILDKIT_PROGRESS=plain \
    DOCKER_BUILDKIT=1 \
    BUILDKIT_STEP_LOG_MAX_SIZE=${BUILDKIT_STEP_LOG_MAX_SIZE}

# Set compiler optimization flags
ENV CFLAGS="-O2 -pipe -march=x86-64 -mtune=generic -fstack-protector-strong -fno-plt" \
    CXXFLAGS="-O2 -pipe -march=x86-64 -mtune=generic -fstack-protector-strong -fno-plt" \
    LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now" \
    RUSTFLAGS="-C target-cpu=x86-64"

# Create logging setup
RUN mkdir -p /lfs-build/logs && \
    touch /lfs-build/logs/build.log && \
    chown -R lfs-builder:lfs-builder /lfs-build/logs

# Create build validation script
RUN cat > /lfs-build/validate-build-env.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "=== LFS Build Environment Validation ==="
echo "Timestamp: $(date)"
echo "User: $(whoami)"
echo "Working Directory: $(pwd)"
echo "LFS Directory: ${LFS}"
echo "Build Profile: ${BUILD_PROFILE}"
echo "Parallel Jobs: ${PARALLEL_JOBS}"
echo ""

# Check essential directories
echo "Checking directories..."
for dir in "${LFS}" "${LFS_WORKSPACE}" "/lfs-build/logs" "/lfs-build/output"; do
    if [[ -d "$dir" ]]; then
        echo "✓ $dir exists"
    else
        echo "✗ $dir missing"
        exit 1
    fi
done

# Check essential tools
echo "Checking essential tools..."
essential_tools=(
    "gcc" "g++" "make" "ld" "as" "ar" "ranlib" "strip" "objcopy" "objdump"
    "git" "wget" "curl" "tar" "gzip" "bzip2" "xz" "unzip"
    "gawk" "sed" "grep" "find" "xargs" "sort" "uniq" "wc"
    "patch" "diff" "cmp" "file" "which" "id" "chmod" "chown"
    "python" "python3" "makeinfo" "bison" "flex" "m4"
)
EOF