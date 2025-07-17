# AGENTS.md - Auto-LFS-Builder Project

## 🔧 Project Manager for Auto-LFS-Builder
🔗 Repository: https://github.com/c1nderscript/Auto-LFS-Builder

## 🎯 Project Overview

The Auto-LFS-Builder project automates the creation of Linux From Scratch (LFS) systems with support for various build profiles including desktop GNOME, minimal, server, and developer configurations. The project integrates the best features of jhalfs (Just another Linux From Scratch automation suite) into a modern Docker-based build system for deterministic, reproducible builds.

## 📍 Critical Path Information

### Primary Paths
- **LFS Build Directory**: `/mnt/lfs` (THE MAIN BUILD LOCATION)
- **Repository Location**: `/mnt/Auto-LFS-Builder`
- **Workspace Directory**: `/mnt/lfs/workspace` or `/lfs-build/workspace` (in container)
- **Log Directory**: `/mnt/Auto-LFS-Builder/logs`
- **Config Directory**: `/mnt/Auto-LFS-Builder/config`
- **jhalfs Integration**: `/mnt/Auto-LFS-Builder/jhalfs` (automated build scripts)
- **Build Control**: `/mnt/Auto-LFS-Builder/control` (jhalfs-style control files)

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

# jhalfs Integration Variables
export JHALFS_DIR=/mnt/Auto-LFS-Builder/jhalfs
export CONTROL_DIR=/mnt/Auto-LFS-Builder/control
export CUSTOM_CONFIG=/mnt/Auto-LFS-Builder/config/lfs-config.xml
export BLFS_TOOL=yes
export OPTIMIZE=2
export STRIP=yes
export VIMLANG=yes
export TIMEZONE=UTC
export PAGE_SIZE=letter
export LANG=en_US.UTF-8
```

### Environment Activation Protocol
```bash
# REQUIRED SEQUENCE - Execute BEFORE any build action
cd /mnt/Auto-LFS-Builder
source ./lfs-builder.env
source ./activate
source ./jhalfs/envvars.conf
```

## 🚀 Codex Agent Bootstrapping (Ubuntu 22.04)

**ENHANCED SETUP WITH JHALFS INTEGRATION - Execute BEFORE any task**:

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

# jhalfs Integration Environment
ENV JHALFS_DIR=/mnt/Auto-LFS-Builder/jhalfs
ENV CONTROL_DIR=/mnt/Auto-LFS-Builder/control
ENV CUSTOM_CONFIG=/mnt/Auto-LFS-Builder/config/lfs-config.xml
ENV BLFS_TOOL=yes
ENV OPTIMIZE=2
ENV STRIP=yes
ENV VIMLANG=yes
ENV TIMEZONE=UTC
ENV PAGE_SIZE=letter
ENV LANG=en_US.UTF-8

# Required packages for LFS building with jhalfs
REQUIREMENTS: build-essential,bison,flex,gawk,texinfo,wget,curl,git,bash,binutils,coreutils,diffutils,findutils,grep,gzip,m4,make,patch,sed,tar,xz-utils,docker.io,docker-compose,libxml2-utils,xsltproc,docbook-xml,docbook-xsl,libxml2-dev,libxslt1-dev,subversion

# Critical paths
PATH_ADDITIONS: /tools/bin:/usr/local/bin:$JHALFS_DIR/bin
WORKING_DIR: /mnt/Auto-LFS-Builder
```

### 2. Create executable codex_script.sh
```bash
#!/bin/bash
set -euo pipefail

echo "=== Codex Agent Environment Setup with jhalfs Integration ==="

# Validate critical paths
echo "Validating critical paths..."
for path in "/mnt/lfs" "/mnt/Auto-LFS-Builder"; do
    if [[ ! -d "$path" ]]; then
        echo "ERROR: $path does not exist"
        exit 1
    fi
done

# Update system and install required packages
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y build-essential bison flex gawk texinfo wget curl git bash binutils coreutils diffutils findutils grep gzip m4 make patch sed tar xz-utils docker.io docker-compose libxml2-utils xsltproc docbook-xml docbook-xsl libxml2-dev libxslt1-dev subversion

# Create necessary directories
echo "Setting up LFS directory structure..."
sudo mkdir -p /mnt/lfs/{sources,tools,workspace,build-logs,control}
sudo chown -R $(whoami):$(whoami) /mnt/lfs

# Set up jhalfs directory structure
echo "Setting up jhalfs integration..."
mkdir -p /mnt/Auto-LFS-Builder/jhalfs/{bin,configs,profiles,templates}
mkdir -p /mnt/Auto-LFS-Builder/control/{build-order,dependencies,custom-scripts}
mkdir -p /mnt/Auto-LFS-Builder/config

# Create jhalfs-style build control files
cat > /mnt/Auto-LFS-Builder/control/build-order/critical-scripts.list << 'EOF'
# Critical build scripts in dependency order
01-binutils-pass1
02-gcc-pass1
03-linux-api-headers
04-glibc
05-libstdc++
06-binutils-pass2
07-gcc-pass2
08-tcl
09-expect
10-dejagnu
11-m4
12-ncurses
13-bash
14-bison
15-bzip2
EOF

# Create jhalfs-style configuration template
cat > /mnt/Auto-LFS-Builder/config/lfs-config.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<lfs-config>
  <general>
    <version>12.0</version>
    <build-profile>desktop_gnome</build-profile>
    <optimization-level>2</optimization-level>
    <parallel-jobs>16</parallel-jobs>
    <strip-binaries>yes</strip-binaries>
    <create-iso>yes</create-iso>
  </general>
  
  <features>
    <gnome-desktop>true</gnome-desktop>
    <networking>true</networking>
    <blfs-tools>true</blfs-tools>
    <systemd>true</systemd>
    <vim-language>true</vim-language>
  </features>
  
  <paths>
    <lfs-mount>/mnt/lfs</lfs-mount>
    <sources>/mnt/lfs/sources</sources>
    <tools>/mnt/lfs/tools</tools>
    <workspace>/mnt/lfs/workspace</workspace>
  </paths>
</lfs-config>
EOF

# Set up environment
export PATH=/tools/bin:/mnt/Auto-LFS-Builder/jhalfs/bin:$PATH
export LFS=/mnt/lfs
export LFS_WORKSPACE=/mnt/lfs/workspace

# Change to working directory
cd /mnt/Auto-LFS-Builder

# Source project environment
if [[ -f "./lfs-builder.env" ]]; then
    source ./lfs-builder.env
fi

if [[ -f "./activate" ]]; then
    source ./activate
fi

if [[ -f "./jhalfs/envvars.conf" ]]; then
    source ./jhalfs/envvars.conf
fi

echo "✅ Codex environment setup complete with jhalfs integration"
echo "LFS: $LFS"
echo "Workspace: $LFS_WORKSPACE"
echo "Build Profile: $BUILD_PROFILE"
echo "jhalfs Directory: /mnt/Auto-LFS-Builder/jhalfs"
echo "Control Directory: /mnt/Auto-LFS-Builder/control"
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
**Last Update**: 2025-07-17 (jhalfs Integration Setup)

## 🔥 Current Task (UPDATED PER FAILURE)

**Status**: READY FOR CRITICAL SCRIPT MODIFICATION
**Task Type**: JHALFS INTEGRATION & BUILD SCRIPT ENHANCEMENT
**Priority**: HIGH

**INSTRUCTION TO CODEX AGENTS**:
You are now **AUTHORIZED** to modify critical build scripts to integrate jhalfs best practices. Focus on:

1. **Deterministic Build Order**: Use jhalfs-style dependency resolution
2. **Error Recovery**: Implement checkpoint/resume functionality
3. **Build Optimization**: Integrate parallel processing and ccache
4. **Package Management**: Add package verification and integrity checks
5. **Logging Enhancement**: Implement detailed build progress tracking

**Required Actions for Codex**:

1. **Analyze Current Build Scripts**:
   - Review `/mnt/Auto-LFS-Builder/scripts/` directory structure
   - Identify critical build scripts that need jhalfs integration
   - Map current build order against jhalfs best practices

2. **Integrate jhalfs Features**:
   - Implement dependency-aware build ordering
   - Add checkpoint/resume capability for failed builds
   - Integrate package verification and integrity checking
   - Add progress tracking and detailed logging

3. **Create Control Templates**:
   - Generate jhalfs-style control files for each build phase
   - Create dependency mapping for all LFS packages
   - Implement build profile switching (minimal/desktop/server/developer)

4. **Enhance Error Handling**:
   - Add intelligent error detection and categorization
   - Implement automatic retry mechanisms for transient failures
   - Create detailed error reporting with build context

5. **Optimize Build Performance**:
   - Integrate ccache for faster rebuilds
   - Implement parallel compilation where safe
   - Add disk space monitoring and cleanup

**Success Criteria**:
- Build scripts use jhalfs-style dependency resolution
- Checkpoint/resume functionality implemented
- Build process is fully deterministic and reproducible
- Error recovery and retry mechanisms working
- Performance optimizations integrated

**Files You Can Modify**:
- `/mnt/Auto-LFS-Builder/scripts/*.sh`
- `/mnt/Auto-LFS-Builder/control/*`
- `/mnt/Auto-LFS-Builder/jhalfs/*`
- `/mnt/Auto-LFS-Builder/config/*`
- `/mnt/Auto-LFS-Builder/Dockerfile`
- `/mnt/Auto-LFS-Builder/docker-compose.yml`

## 🏗️ JHALFS INTEGRATION ARCHITECTURE

### Build Control System
```bash
# jhalfs-style build control structure
$CONTROL_DIR/
├── build-order/
│   ├── 01-toolchain.list      # Cross-compilation toolchain
│   ├── 02-system.list         # Base system packages
│   ├── 03-networking.list     # Network stack
│   ├── 04-desktop.list        # Desktop environment
│   └── 05-applications.list   # User applications
├── dependencies/
│   ├── package-deps.xml       # Package dependency mapping
│   ├── build-deps.xml         # Build-time dependencies
│   └── runtime-deps.xml       # Runtime dependencies
├── custom-scripts/
│   ├── pre-build/            # Pre-build customizations
│   ├── post-build/           # Post-build customizations
│   └── package-specific/     # Package-specific modifications
└── profiles/
    ├── minimal.conf          # Minimal build profile
    ├── desktop_gnome.conf    # GNOME desktop profile
    ├── server.conf           # Server profile
    └── developer.conf        # Development profile
```

### Enhanced Build Script Template
```bash
#!/bin/bash
# Enhanced LFS build script with jhalfs integration

set -euo pipefail

# Source jhalfs environment
source "$JHALFS_DIR/envvars.conf"
source "$CONTROL_DIR/profiles/${BUILD_PROFILE}.conf"

# jhalfs-style functions
jhalfs_log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_PATH"
}

jhalfs_check_deps() {
    local package="$1"
    local deps_file="$CONTROL_DIR/dependencies/package-deps.xml"
    
    if [[ -f "$deps_file" ]]; then
        xmllint --xpath "//package[@name='$package']/dependency/@name" "$deps_file" 2>/dev/null | \
        sed 's/name="//g; s/"//g' | tr ' ' '\n' | while read dep; do
            if [[ -n "$dep" ]] && ! jhalfs_is_installed "$dep"; then
                jhalfs_log "ERROR" "Missing dependency: $dep for package $package"
                return 1
            fi
        done
    fi
}

jhalfs_is_installed() {
    local package="$1"
    # Check if package is installed using various methods
    command -v "$package" >/dev/null 2>&1 || \
    [[ -f "/tools/bin/$package" ]] || \
    [[ -f "/usr/bin/$package" ]] || \
    [[ -f "/usr/local/bin/$package" ]]
}

jhalfs_create_checkpoint() {
    local phase="$1"
    local checkpoint_file="$LFS_WORKSPACE/checkpoints/$phase.checkpoint"
    
    mkdir -p "$(dirname "$checkpoint_file")"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $phase completed successfully" > "$checkpoint_file"
    jhalfs_log "INFO" "Checkpoint created: $phase"
}

jhalfs_resume_from_checkpoint() {
    local phase="$1"
    local checkpoint_file="$LFS_WORKSPACE/checkpoints/$phase.checkpoint"
    
    if [[ -f "$checkpoint_file" ]]; then
        jhalfs_log "INFO" "Resuming from checkpoint: $phase"
        return 0
    else
        return 1
    fi
}

jhalfs_build_package() {
    local package="$1"
    local source_dir="$2"
    local build_script="$3"
    
    jhalfs_log "INFO" "Starting build: $package"
    
    # Check if already built
    if jhalfs_resume_from_checkpoint "$package"; then
        jhalfs_log "INFO" "Package $package already built, skipping"
        return 0
    fi
    
    # Check dependencies
    if ! jhalfs_check_deps "$package"; then
        jhalfs_log "ERROR" "Dependency check failed for $package"
        return 1
    fi
    
    # Execute build script with error handling
    if bash "$build_script" "$source_dir"; then
        jhalfs_create_checkpoint "$package"
        jhalfs_log "SUCCESS" "Package $package built successfully"
    else
        jhalfs_log "ERROR" "Package $package build failed"
        return 1
    fi
}

# Example usage in main build script
main() {
    jhalfs_log "INFO" "Starting jhalfs-enhanced LFS build"
    
    # Load build order from control files
    while IFS= read -r package_spec; do
        [[ "$package_spec" =~ ^#.*$ ]] && continue  # Skip comments
        [[ -z "$package_spec" ]] && continue       # Skip empty lines
        
        package_name=$(echo "$package_spec" | cut -d':' -f1)
        package_dir=$(echo "$package_spec" | cut -d':' -f2)
        build_script=$(echo "$package_spec" | cut -d':' -f3)
        
        if ! jhalfs_build_package "$package_name" "$package_dir" "$build_script"; then
            jhalfs_log "ERROR" "Build failed at package: $package_name"
            exit 1
        fi
        
    done < "$CONTROL_DIR/build-order/01-toolchain.list"
    
    jhalfs_log "SUCCESS" "jhalfs-enhanced LFS build completed successfully"
}

main "$@"
```

### Package Verification System
```bash
#!/bin/bash
# jhalfs-style package verification

jhalfs_verify_package() {
    local package="$1"
    local expected_files="$2"
    local verification_script="$CONTROL_DIR/verification/${package}.verify"
    
    jhalfs_log "INFO" "Verifying package: $package"
    
    # Run package-specific verification if available
    if [[ -f "$verification_script" ]]; then
        if bash "$verification_script"; then
            jhalfs_log "SUCCESS" "Package $package verification passed"
            return 0
        else
            jhalfs_log "ERROR" "Package $package verification failed"
            return 1
        fi
    fi
    
    # Default verification: check expected files
    for file in $expected_files; do
        if [[ ! -f "$file" ]]; then
            jhalfs_log "ERROR" "Missing expected file: $file for package $package"
            return 1
        fi
    done
    
    jhalfs_log "SUCCESS" "Package $package verification passed (default)"
    return 0
}
```

## 🔒 ENHANCED WARP TERMINAL AGENT RULES

### Rule 1: MANDATORY PATH AND JHALFS VALIDATION
```bash
# BEFORE ANY TOOL EXECUTION - VALIDATE PATHS INCLUDING JHALFS
REQUIRED_PATHS: [
    "/mnt/lfs",
    "/mnt/Auto-LFS-Builder",
    "/mnt/Auto-LFS-Builder/install.sh",
    "/mnt/Auto-LFS-Builder/lfs-build.sh",
    "/mnt/Auto-LFS-Builder/lfs-builder.env",
    "/mnt/Auto-LFS-Builder/jhalfs",
    "/mnt/Auto-LFS-Builder/control",
    "/mnt/Auto-LFS-Builder/config/lfs-config.xml"
]

FOR_EACH_PATH:
    IF NOT EXISTS: create_github_issue("Missing Critical Path: $PATH")
    THEN: terminate_session()
```

### Rule 2: ENHANCED ENVIRONMENT ACTIVATION PROTOCOL
```bash
# MANDATORY - Execute BEFORE any build action
REQUIRED_SEQUENCE: [
    "cd /mnt/Auto-LFS-Builder",
    "source ./lfs-builder.env",
    "source ./activate",
    "source ./jhalfs/envvars.conf"
]

VALIDATION_COMMANDS: [
    "echo $LFS",
    "echo $LFS_WORKSPACE", 
    "echo $BUILD_PROFILE",
    "echo $JHALFS_DIR",
    "echo $CONTROL_DIR"
]

IF_VALIDATION_FAILS: create_github_issue("Enhanced Environment Activation Failed")
```

### Rule 3: INTELLIGENT BUILD FAILURE DETECTION & RECOVERY
```bash
# ENHANCED ERROR HANDLING WITH JHALFS INTEGRATION
MONITOR_COMMANDS: [
    "docker-compose logs -f lfs-builder",
    "tail -f /mnt/Auto-LFS-Builder/logs/build.log",
    "./lfs-validate",
    "tail -f $LFS_WORKSPACE/checkpoints/*.checkpoint"
]

ERROR_PATTERNS: [
    "ERROR:",
    "FAILED:",
    "make.*Error",
    "configure: error",
    "No space left on device",
    "Permission denied",
    "command not found",
    "jhalfs.*failed",
    "dependency.*missing",
    "checkpoint.*corrupted"
]

ON_ERROR_DETECTED: {
    EXTRACT_CONTEXT: {
        "file_path": "$(grep -n 'ERROR' logfile | head -1)",
        "error_message": "$(grep -A10 -B10 'ERROR' logfile)",
        "build_phase": "$(grep 'Building\|jhalfs.*starting' logfile | tail -1)",
        "last_checkpoint": "$(ls -t $LFS_WORKSPACE/checkpoints/*.checkpoint | head -1)",
        "package_being_built": "$(tail -20 $LOG_PATH | grep -o 'Starting build: [^[:space:]]*' | tail -1)"
    }
    
    ATTEMPT_RECOVERY: {
        "resume_from_checkpoint": "$(cat $last_checkpoint)",
        "clean_partial_build": "make clean in current package dir",
        "retry_with_verbose": "rebuild with VERBOSE=true DEBUG=1"
    }
    
    CREATE_ENHANCED_ISSUE: {
        "title": "LFS Build Failure with jhalfs Integration: [specific_error]",
        "body": "**Error**: [error_message]\n**File**: [file_path]\n**Phase**: [build_phase]\n**Package**: [package_being_built]\n**Last Checkpoint**: [last_checkpoint]\n**Recovery Attempted**: [recovery_actions]\n**Context**: [extended_log_snippet]",
        "labels": ["lfs-build-failure", "jhalfs-integration", "priority:high", "recovery-attempted"]
    }
    
    IF_RECOVERY_FAILED: terminate_session()
}
```

## 🛠️ ENHANCED MCP TOOL CONFIGURATION

### GitHub MCP Server with jhalfs Integration
```json
{
  "name": "github-lfs-jhalfs",
  "command": "github-mcp-server",
  "args": ["--token", "${GITHUB_TOKEN}"],
  "env": {
    "GITHUB_OWNER": "c1nderscript",
    "GITHUB_REPO": "Auto-LFS-Builder",
    "JHALFS_INTEGRATION": "true",
    "BUILD_SYSTEM": "jhalfs-enhanced"
  },
  "start_on_launch": true
}
```

### Enhanced Code Sandbox MCP
```json
{
  "name": "lfs-jhalfs-sandbox",
  "command": "code-sandbox-mcp",
  "args": ["--image", "ubuntu:22.04"],
  "env": {
    "WORKSPACE": "/workspace",
    "LFS_DIR": "/mnt/lfs",
    "JHALFS_DIR": "/mnt/Auto-LFS-Builder/jhalfs",
    "CONTROL_DIR": "/mnt/Auto-LFS-Builder/control",
    "BUILD_SYSTEM": "jhalfs"
  },
  "start_on_launch": false
}
```

## 🏗️ ENHANCED BUILD PROCESS WORKFLOWS

### jhalfs-Enhanced Build Workflow
1. **Pre-Build Phase**: 
   - Load jhalfs configuration and profiles
   - Validate all dependencies and build order
   - Create initial checkpoints
   
2. **Toolchain Phase**: 
   - Build cross-compilation toolchain using jhalfs dependency resolution
   - Verify each tool before proceeding
   - Create toolchain checkpoint
   
3. **System Phase**: 
   - Build base system packages in dependency order
   - Implement package verification at each step
   - Use checkpoint/resume for any failures
   
4. **Feature Phase**: 
   - Build profile-specific packages (GNOME, networking, etc.)
   - Apply custom configurations
   - Create feature-specific checkpoints
   
5. **Finalization Phase**: 
   - System configuration and optimization
   - ISO creation if enabled
   - Final system verification

### Enhanced Build Monitoring Commands
```bash
# Primary monitoring commands with jhalfs integration
docker-compose logs -f lfs-builder
tail -f /mnt/Auto-LFS-Builder/logs/build.log
tail -f $LFS_WORKSPACE/checkpoints/current.log
watch -n 30 'df -h /mnt/lfs && echo "=== Build Progress ===" && ls -la $LFS_WORKSPACE/checkpoints/'
docker stats --no-stream
```

### Enhanced Build Profiles
- **minimal**: jhalfs base LFS system with checkpoint recovery
- **desktop_gnome**: Full GNOME desktop with jhalfs dependency resolution
- **server**: Server configuration with networking, optimized package selection
- **developer**: Development tools with enhanced build system integration

## 🔍 ENHANCED VALIDATION REQUIREMENTS

### Pre-Build Validation Checklist with jhalfs
- [ ] All required paths exist and are accessible
- [ ] Environment variables properly set (including jhalfs vars)
- [ ] Docker and docker-compose installed and running
- [ ] Minimum 50GB free space in `/mnt/lfs`
- [ ] All required build tools available
- [ ] Network connectivity for package downloads
- [ ] jhalfs control files properly configured
- [ ] Build profile configuration validated
- [ ] XML configuration files valid

### Post-Build Validation with jhalfs
- [ ] LFS system successfully created
- [ ] All build phases completed without errors
- [ ] All checkpoints created successfully
- [ ] Package verification passed for all components
- [ ] ISO file created (if enabled)
- [ ] System boots successfully
- [ ] All required packages installed and verified
- [ ] jhalfs integration working correctly

## 📋 ENHANCED COMMON ISSUES AND SOLUTIONS

### Issue: jhalfs Dependency Resolution Failure
**Symptoms**: Build stops with missing dependency error
**Diagnosis**: Check `$CONTROL_DIR/dependencies/package-deps.xml`
**Action**: Modify dependency mapping and retry build

### Issue: Checkpoint Recovery Failure
**Symptoms**: Cannot resume from checkpoint
**Diagnosis**: Check checkpoint file integrity
**Action**: Create issue with checkpoint status and rebuild from last valid checkpoint

### Issue: Package Verification Failure
**Symptoms**: Package verification script fails
**Diagnosis**: Check verification criteria and actual package contents
**Action**: Update verification script or fix package build process

### Issue: Build Profile Configuration Error
**Symptoms**: Incorrect packages being built for profile
**Diagnosis**: Check profile configuration in `$CONTROL_DIR/profiles/`
**Action**: Fix profile configuration and restart build

## 🚨 ENHANCED EMERGENCY PROCEDURES

### Build Failure Recovery with jhalfs
1. **Identify Last Valid Checkpoint**: Check `$LFS_WORKSPACE/checkpoints/`
2. **Analyze Failure Point**: Review build logs and error context
3. **Attempt Automated Recovery**: Use jhalfs resume functionality
4. **Manual Intervention**: If automated recovery fails, create detailed GitHub issue
5. **Clean Restart**: If all else fails, restart from last major checkpoint

### Performance Optimization Emergency
1. **Check Resource Usage**: Monitor CPU, memory, and disk usage
2. **Enable ccache**: If not already enabled, activate ccache for faster rebuilds
3. **Adjust Parallelism**: Reduce `PARALLEL_JOBS` if system is overloaded
4. **Clean Temporary Files**: Remove unnecessary temporary build files

This enhanced AGENTS.md integrates the best features of jhalfs while maintaining the safety and automation features of the original Auto-LFS-Builder project. Codex agents can now safely modify critical build scripts to implement deterministic builds, error recovery, and performance optimizations.