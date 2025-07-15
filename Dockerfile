FROM archlinux:latest

# Install base and LFS dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    gawk \
    m4 \
    texinfo \
    bison \
    flex \
    bc \
    cpio \
    dosfstools \
    parted \
    rsync \
    unzip \
    which \
    pkgconf \
    autoconf \
    automake \
    libtool \
    patch \
    python \
    python-pip \
    qemu-system-x86 \
    libisoburn \
    squashfs-tools \
    inotify-tools \
    coreutils \
    procps-ng \
    ccache \
    findutils \
    time \
    fakeroot \
    file

# Create non-root user for LFS build
RUN useradd -ms /bin/bash -u 1000 lfs-builder

# Setup working directories
WORKDIR /lfs-build
RUN mkdir -p /mnt/lfs && \
    chown -R lfs-builder:lfs-builder /mnt/lfs /lfs-build

# Copy source files and set correct ownership
COPY --chown=lfs-builder:lfs-builder . .

# Set environment variables for LFS build
ENV HOME=/lfs-build \
    LFS=/mnt/lfs \
    LC_ALL=POSIX \
    MAKEFLAGS="-j$(nproc)" \
    PATH=/usr/lib/ccache/bin:/usr/bin \
    CONFIG_SHELL=/bin/bash \
    SHELL=/bin/bash

# Set up ccache symlinks
RUN mkdir -p /usr/lib/ccache/bin && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/gcc && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/g++ && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/cc && \
    ln -sf /usr/bin/ccache /usr/lib/ccache/bin/c++

# Create required build subdirs as user
USER lfs-builder
RUN mkdir -p workspace output logs

# Entry point into build script
ENTRYPOINT ["bash", "-euxo", "pipefail", "./lfs-build.sh"]

