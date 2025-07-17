# 🐳 Docker-Based LFS Build Guide

This guide covers the Docker-based build process for Auto-LFS-Builder in detail.

## Why Use Docker?

Building LFS requires a specific environment with exact versions of tools and libraries. Docker ensures:

- 🔒 **Isolation**: Build process doesn't affect your system
- 🔄 **Reproducibility**: Same environment every time
- 💾 **Persistence**: Build progress saved between sessions
- 🛠️ **Zero Setup**: All dependencies included
- 📊 **Resource Control**: Easy CPU/memory management

## Prerequisites

- Docker Engine 20.10+
- Docker Compose V2
- 50GB disk space
- 4GB RAM (8GB recommended)

## Quick Start

```bash
# Clone repository
git clone https://github.com/c1nderscript/Auto-LFS-Builder.git
cd Auto-LFS-Builder

# Start build
docker compose up --build
```

## Directory Setup

Before running the container, create the directories used for bind mounts and
ensure they are writable by Docker:

```bash
mkdir -p output lfs-mount .ccache
sudo chown -R 1000:1000 output lfs-mount .ccache
```

Run `docker compose up --build` after preparing these directories.

## Container Structure

The build container uses several mounted volumes:

```yaml
volumes:
  - ./workspace:/lfs-build/workspace  # Source packages
  - ./logs:/lfs-build/logs           # Build logs
  - lfs_output:/lfs-build/output     # Build outputs
  - lfs_mount:/mnt/lfs               # LFS system
```

## Configuration

### Resource Management

Edit `docker-compose.yml`:

```yaml
environment:
  PARALLEL_JOBS: 32     # CPU cores to use
  BUILD_PROFILE: "desktop_gnome"  # Build type
  GNOME_ENABLED: "true"
  NETWORKING_ENABLED: "true"
  CREATE_ISO: "true"
```

### Build Profiles

Available profiles:
- `desktop_gnome`: Full desktop
- `minimal`: Base system
- `server`: Server setup
- `developer`: Development tools

### System Requirements

The container needs certain privileges:

```yaml
privileged: true
cap_add:
  - ALL
security_opt:
  - seccomp:unconfined
  - apparmor:unconfined
```

## Build Process

1. **Container Creation**
   - Base image pulled/built
   - Volumes mounted
   - Environment prepared

2. **Source Download**
   - Packages downloaded to `workspace/`
   - Checksums verified

3. **Cross-Toolchain**
   - Initial tools built
   - Host-independent toolchain created

4. **Core System**
   - Base LFS system built
   - Essential utilities installed

5. **Configuration**
   - System settings applied
   - Users/groups created

6. **Desktop (Optional)**
   - GNOME desktop installed
   - Graphics drivers configured

7. **Finalization**
   - System image created
   - Build logs saved

## Monitoring Progress

View build progress:
```bash
# Follow build logs
docker compose logs -f

# Check build log file
tail -f logs/build.log
```

## Managing Builds

```bash
# Stop build (preserves progress)
docker compose down

# Resume build
docker compose up

# Clean and restart
docker compose down -v
docker compose up --build
```

## Troubleshooting

### Common Issues

1. **Resource Limits**
   ```bash
   # Check Docker resources
   docker info
   
   # Increase limits in daemon.json
   {
     "memory": "8g",
     "cpu-shares": 8192
   }
   ```

2. **Storage Issues**
   ```bash
   # Check space
   docker system df
   
   # Clean unused data
   docker system prune
   ```

3. **Permission Problems**
   ```bash
   # Fix volume permissions
   sudo chown -R 1000:1000 workspace logs
   ```

### Debug Mode

Enable debug output:
```yaml
environment:
  DEBUG: 1
  V: 1
  SHELL: "/bin/bash -x"
```

## Best Practices

1. **Resource Management**
   - Allocate enough CPU cores
   - Ensure sufficient RAM
   - Monitor disk space

2. **Data Persistence**
   - Use named volumes
   - Back up important data
   - Clean unused volumes

3. **Security**
   - Review container privileges
   - Monitor resource usage
   - Update base images

## Output Files

After successful build:

- **/mnt/lfs**: Complete LFS system
- **workspace/**: Build artifacts
- **logs/**: Build logs

## Next Steps

1. **Create Boot Media**
   ```bash
   # Extract system
   sudo tar -xf workspace/lfs-system.tar.gz -C /mnt/target
   ```

2. **Install Bootloader**
   ```bash
   # Install GRUB
   sudo grub-install --target=i386-pc /dev/sdX
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

3. **First Boot**
   - Boot new system
   - Complete initial setup
   - Install additional software

## Support

For issues:
1. Check logs in `logs/`
2. Review Docker logs
3. Open GitHub issue

