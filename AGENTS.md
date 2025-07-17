# AGENTS.md - Auto-LFS-Builder Project

## 🔧 Project Manager for Auto-LFS-Builder
🔗 Repository: https://github.com/c1nderscript/Auto-LFS-Builder

## 🎯 Project Overview

The Auto-LFS-Builder project automates the creation of Linux From Scratch (LFS) systems with support for various build profiles including desktop GNOME, minimal, server, and developer configurations. The project uses Docker containers for isolated building and supports both host-based and containerized execution environments.

## 📍 Critical Path Information

### Primary Paths
- **LFS Build Directory**: `/mnt/lfs` (THE MAIN BUILD LOCATION)
- **Repository Location**: `/mnt/Auto-LFS-Builder`
- **Workspace Directory**: `/mnt/lfs/workspace` or `/lfs-build/workspace` (in container)
- **Log Directory**: `/mnt/Auto-LFS-Builder/logs`
- **Config Directory**: `/mnt/Auto-LFS-Builder/config`

### Essential Environment Variables
```bash
# MANDATORY - Source these before ANY action
export LFS=/mnt/lfs
export LFS_WORKSPACE=/mnt/lfs/workspace
export BUILD_PROFILE=desktop_gnome
export PARALLEL_JOBS=16
export GNOME_ENABLED=true
export NETWORKING_ENABLED=true
export CREATE_ISO=true
export LOG_PATH=/mnt/Auto-LFS-Builder/logs/build.log
export VERBOSE=true
export DEBUG=1
```

### Environment Activation Protocol
```bash
# REQUIRED SEQUENCE - Execute BEFORE any build action
cd /mnt/Auto-LFS-Builder
source ./lfs-builder.env
source ./activate
```

## 🚀 Codex Agent Bootstrapping (Ubuntu 22.04)

**MANDATORY SETUP - Execute BEFORE any task**:

### 1. Create codex_environment.md
```markdown
# codex_environment.md
ENV UBUNTU_VERSION=22.04
ENV LFS=/mnt/lfs
ENV LFS_WORKSPACE=/mnt/lfs/workspace
ENV BUILD_PROFILE=desktop_gnome
ENV PARALLEL_JOBS=16
ENV MAKEFLAGS=-j16
ENV GNOME_ENABLED=true
ENV NETWORKING_ENABLED=true
ENV CREATE_ISO=true
ENV LOG_PATH=/mnt/Auto-LFS-Builder/logs/build.log
ENV VERBOSE=true
ENV DEBUG=1

# Required packages for LFS building
REQUIREMENTS: build-essential,bison,flex,gawk,texinfo,wget,curl,git,bash,binutils,coreutils,diffutils,findutils,grep,gzip,m4,make,patch,sed,tar,xz-utils,docker.io,docker-compose

# Critical paths
PATH_ADDITIONS: /tools/bin:/usr/local/bin
WORKING_DIR: /mnt/Auto-LFS-Builder
```

### 2. Create executable codex_script.sh
```bash
#!/bin/bash
set -euo pipefail

# Source environment variables
source codex_environment.md

# Validate critical paths
echo "Validating critical paths..."
if [[ ! -d "/mnt/lfs" ]]; then
    echo "ERROR: /mnt/lfs does not exist"
    exit 1
fi

if [[ ! -d "/mnt/Auto-LFS-Builder" ]]; then
    echo "ERROR: /mnt/Auto-LFS-Builder does not exist"
    exit 1
fi

# Update system and install required packages
sudo apt-get update
sudo apt-get install -y build-essential bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils grep gzip m4 make patch sed tar xz-utils docker.io docker-compose

# Create necessary directories
sudo mkdir -p $LFS/sources $LFS/tools $LFS/workspace
sudo chown -R $(whoami):$(whoami) $LFS

# Set up environment
export PATH=/tools/bin:$PATH
export LFS=/mnt/lfs
export LFS_WORKSPACE=/mnt/lfs/workspace

# Change to working directory
cd /mnt/Auto-LFS-Builder

# Source project environment
source ./lfs-builder.env
source ./activate

echo "Codex environment setup complete"
echo "LFS: $LFS"
echo "Workspace: $LFS_WORKSPACE"
echo "Build Profile: $BUILD_PROFILE"
```

### 3. Execute setup
```bash
chmod +x codex_script.sh
./codex_script.sh
```

## 📊 Current Build Status (AUTO-UPDATED)

**Active Build**: NO
**Build Profile**: desktop_gnome
**Current Phase**: Initialization
**Progress**: 0% complete
**Estimated Time Remaining**: N/A
**Last Update**: 2025-07-16 (Initial setup)

## 🔥 Current Task (UPDATED PER FAILURE)

**Status**: BLOCKED - INFRASTRUCTURE CHANGE
**Task Type**: VARIABLE RENAMING REQUEST
**Priority**: HIGH

**Required Action for Codex**:
1. Create GitHub issue describing the requested rename of `ENABLE_GNOME` to `GNOME_ENABLED` and `ENABLE_NETWORKING` to `NETWORKING_ENABLED`.
2. Await maintainer approval before modifying any build scripts or environment files.

**Success Criteria**:
- GitHub issue created with details of the requested change.
- Maintainer approves the infrastructure update.

**Next Steps**: Update this task section once approval is granted.

## ⚠️ CODEX SAFETY DIRECTIVE

**INFRASTRUCTURE/UNSAFE CHANGES DETECTED**:
DO NOT MODIFY CODE. Instead:

1. **Create GitHub Issue**:
   ```json
   {
     "title": "Infrastructure Change Required: [description]",
     "body": "**Error**: [error_summary]\n**File**: [file_path]\n**Action**: [required_change]\n**Logs**: [relevant_snippet]\n**Build Phase**: [current_phase]\n**Container Status**: [docker_ps_output]",
     "labels": ["infra", "priority:high", "codex-escalation"]
   }
   ```

2. **Update AGENTS.md Current Task Section**
3. **TERMINATE SESSION IMMEDIATELY**

**Forbidden Actions**:
- Direct file modifications in `/mnt/lfs`
- Docker system prune operations
- Changing critical build scripts
- Modifying environment variables without approval
- Removing or recreating containers

## 🔒 WARP TERMINAL AGENT RULES

### Rule 1: MANDATORY PATH VALIDATION
```bash
# BEFORE ANY TOOL EXECUTION - VALIDATE PATHS
REQUIRED_PATHS: [
    "/mnt/lfs",
    "/mnt/Auto-LFS-Builder",
    "/mnt/Auto-LFS-Builder/install.sh",
    "/mnt/Auto-LFS-Builder/lfs-build.sh",
    "/mnt/Auto-LFS-Builder/lfs-builder.env"
]

FOR_EACH_PATH:
    IF NOT EXISTS: create_github_issue("Missing Critical Path: $PATH")
    THEN: terminate_session()
```

### Rule 2: ENVIRONMENT ACTIVATION PROTOCOL
```bash
# MANDATORY - Execute BEFORE any build action
REQUIRED_SEQUENCE: [
    "cd /mnt/Auto-LFS-Builder",
    "source ./lfs-builder.env",
    "source ./activate"
]

VALIDATION_COMMANDS: [
    "echo $LFS",
    "echo $LFS_WORKSPACE", 
    "echo $BUILD_PROFILE"
]

IF_VALIDATION_FAILS: create_github_issue("Environment Activation Failed")
```

### Rule 3: FAILURE DETECTION & ISSUE CREATION
```bash
# MANDATORY ERROR HANDLING
MONITOR_COMMANDS: [
    "docker-compose logs -f lfs-builder",
    "tail -f /mnt/Auto-LFS-Builder/logs/build.log",
    "./lfs-validate"
]

ERROR_PATTERNS: [
    "ERROR:",
    "FAILED:",
    "make.*Error",
    "configure: error",
    "No space left on device",
    "Permission denied",
    "command not found"
]

ON_ERROR_DETECTED: {
    EXTRACT_CONTEXT: {
        "file_path": "$(grep -n 'ERROR' logfile | head -1)",
        "error_message": "$(grep -A5 -B5 'ERROR' logfile)",
        "build_phase": "$(grep 'Building' logfile | tail -1)"
    }
    
    CREATE_ISSUE: {
        "title": "LFS Build Failure: [specific_error]",
        "body": "**Error**: [error_message]\n**File**: [file_path]\n**Phase**: [build_phase]\n**Context**: [log_snippet]",
        "labels": ["lfs-build-failure", "priority:high"]
    }
    
    TERMINATE_SESSION: true
}
```

## 🛠️ MCP Tool Configuration

### GitHub MCP Server
```json
{
  "name": "github-lfs-builder",
  "command": "github-mcp-server",
  "args": ["--token", "${GITHUB_TOKEN}"],
  "env": {
    "GITHUB_OWNER": "c1nderscript",
    "GITHUB_REPO": "Auto-LFS-Builder"
  },
  "start_on_launch": true
}
```

### Code Sandbox MCP
```json
{
  "name": "lfs-sandbox",
  "command": "code-sandbox-mcp",
  "args": ["--image", "ubuntu:22.04"],
  "env": {
    "WORKSPACE": "/workspace",
    "LFS_DIR": "/mnt/lfs"
  },
  "start_on_launch": false
}
```

### Docker MCP Server
```json
{
  "name": "lfs-docker",
  "command": "mcp-server-docker",
  "args": ["--privileged"],
  "env": {
    "DOCKER_BUILDKIT": "1"
  },
  "start_on_launch": false
}
```

## 🏗️ Build Process Workflows

### Standard Build Workflow
1. **Initialization**: Source environment and validate paths
2. **Preparation**: Run `./lfs-validate` to check system readiness
3. **Container Setup**: Start Docker containers with `docker-compose up --build`
4. **Build Execution**: Monitor logs and progress
5. **Completion**: Extract artifacts and create ISO if enabled

### Build Monitoring Commands
```bash
# Primary monitoring commands
docker-compose logs -f lfs-builder
tail -f /mnt/Auto-LFS-Builder/logs/build.log
watch -n 30 'df -h /mnt/lfs'
docker stats --no-stream
```

### Build Profiles Available
- **desktop_gnome**: Full GNOME desktop with networking
- **minimal**: Base LFS system only
- **server**: Server configuration with networking, no GUI
- **developer**: Development tools and environment

## 🔍 Validation Requirements

### Pre-Build Validation Checklist
- [ ] All required paths exist and are accessible
- [ ] Environment variables properly set
- [ ] Docker and docker-compose installed and running
- [ ] Minimum 50GB free space in `/mnt/lfs`
- [ ] All required build tools available
- [ ] Network connectivity for package downloads

### Post-Build Validation
- [ ] LFS system successfully created
- [ ] All build phases completed without errors
- [ ] ISO file created (if enabled)
- [ ] System boots successfully
- [ ] All required packages installed

## 📋 Common Issues and Solutions

### Issue: Docker Container Won't Start
**Symptoms**: `docker-compose up` fails
**Diagnosis**: Check `docker-compose logs lfs-builder`
**Action**: Create issue with full docker logs

### Issue: Build Fails During Compilation
**Symptoms**: make errors in build log
**Diagnosis**: Check specific package being built
**Action**: Create issue with error context and build phase

### Issue: Insufficient Disk Space
**Symptoms**: "No space left on device"
**Diagnosis**: Check `df -h /mnt/lfs`
**Action**: Create issue with disk usage information

### Issue: Permission Denied Errors
**Symptoms**: Permission errors in logs
**Diagnosis**: Check ownership of `/mnt/lfs`
**Action**: Create issue with permission details

## 🚨 Emergency Procedures

### Build Failure Recovery
1. **Stop a
