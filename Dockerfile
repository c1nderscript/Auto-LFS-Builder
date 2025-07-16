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
    strace \
    ldd \
    objdump \
    readelf \
    nm \
    strings

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

for tool in "${essential_tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✓ $tool available"
    else
        echo "✗ $tool missing"
        exit 1
    fi
done

# Check ccache
echo "Checking ccache..."
if command -v ccache >/dev/null 2>&1; then
    echo "✓ ccache available"
    ccache -s || true
else
    echo "✗ ccache missing"
    exit 1
fi

# Check disk space
echo "Checking disk space..."
available_space=$(df /mnt/lfs 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
if [[ $available_space -gt 52428800 ]]; then  # 50GB in KB
    echo "✓ Sufficient disk space: $(( available_space / 1048576 ))GB available"
else
    echo "✗ Insufficient disk space: $(( available_space / 1048576 ))GB available (need 50GB+)"
    exit 1
fi

# Check memory
echo "Checking memory..."
available_memory=$(free -m | awk 'NR==2{print $7}')
if [[ $available_memory -gt 4096 ]]; then
    echo "✓ Sufficient memory: ${available_memory}MB available"
else
    echo "⚠ Low memory: ${available_memory}MB available (recommend 4GB+)"
fi

echo ""
echo "=== Environment validation completed successfully ==="
EOF

# Make validation script executable
RUN chmod +x /lfs-build/validate-build-env.sh && \
    chown lfs-builder:lfs-builder /lfs-build/validate-build-env.sh

# Create enhanced build wrapper script
RUN cat > /lfs-build/build-wrapper.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Enhanced error handling
trap 'echo "Build failed at line $LINENO with exit code $?" | tee -a "$LOG_PATH"' ERR
trap 'echo "Build interrupted" | tee -a "$LOG_PATH"' INT TERM

# Function to log with timestamp
log_message() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_PATH"
}

# Function to check exit status
check_status() {
    local exit_code=$?
    local operation="$1"
    
    if [[ $exit_code -eq 0 ]]; then
        log_message "SUCCESS" "$operation completed successfully"
        return 0
    else
        log_message "ERROR" "$operation failed with exit code $exit_code"
        return $exit_code
    fi
}

# Initialize logging
log_message "INFO" "Starting LFS build process"
log_message "INFO" "Build Profile: $BUILD_PROFILE"
log_message "INFO" "Parallel Jobs: $PARALLEL_JOBS"
log_message "INFO" "User: $(whoami)"
log_message "INFO" "Working Directory: $(pwd)"

# Run environment validation
log_message "INFO" "Running environment validation"
./validate-build-env.sh
check_status "Environment validation"

# Execute the actual build script
log_message "INFO" "Executing LFS build script"
if [[ -f "./lfs-build.sh" ]]; then
    exec ./lfs-build.sh "$@"
else
    log_message "ERROR" "lfs-build.sh not found"
    exit 1
fi
EOF

# Make build wrapper executable
RUN chmod +x /lfs-build/build-wrapper.sh && \
    chown lfs-builder:lfs-builder /lfs-build/build-wrapper.sh

# Switch to lfs-builder user
USER lfs-builder

# Create user-specific directories
RUN mkdir -p /home/lfs-builder/.cache/ccache && \
    mkdir -p /home/lfs-builder/.config

# Set working directory and ensure it's owned by lfs-builder
WORKDIR /lfs-build

# Create health check script
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD test -f /lfs-build/logs/build.log || exit 1

# Add build information
LABEL maintainer="c1nderscript" \
      description="Auto-LFS-Builder optimized Docker container" \
      version="1.0" \
      build_date="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
      vcs_ref="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"

# Entry point with enhanced error handling and logging
ENTRYPOINT ["bash", "-c", "./build-wrapper.sh \"$@\"", "--"]

# Default command
CMD []
