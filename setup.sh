#!/bin/bash
# Auto-LFS-Builder Environment Setup and Initialization Scripts

# =============================================================================
# setup_environment.sh - Initial environment setup
# =============================================================================

setup_lfs_environment() {
    echo "Setting up Auto-LFS-Builder environment..."
    
    # Set LFS environment variables
    export LFS=/mnt/lfs
    export LFS_TGT=$(uname -m)-lfs-linux-gnu
    export PATH=/usr/bin
    
    # Create LFS directory structure
    sudo mkdir -pv $LFS/{etc,var,usr/{bin,lib,sbin}}
    sudo mkdir -pv $LFS/lib64
    sudo mkdir -pv $LFS/{dev,proc,sys,run}
    sudo mkdir -pv $LFS/tmp
    sudo mkdir -pv $LFS/mnt
    sudo mkdir -pv $LFS/media/{floppy,cdrom}
    
    # Set permissions
    sudo chmod -v a+wt $LFS/tmp
    
    # Create tools directory
    sudo mkdir -pv $LFS/tools
    sudo ln -sfv $LFS/tools /
    
    echo "LFS environment setup complete!"
}

# =============================================================================
# initialize_codex_agents.sh - Codex agent initialization
# =============================================================================

initialize_codex_agents() {
    echo "Initializing Codex agents for Auto-LFS-Builder..."
    
    # Set Codex context variables
    export CODEX_PROJECT_TYPE="lfs-automation"
    export CODEX_DOCUMENTATION_PATH="./docs/"
    export CODEX_BUILD_CONTEXT="linux-from-scratch"
    export CODEX_LOG_LEVEL="INFO"
    
    # Create agent working directories
    mkdir -p .codex/{context,cache,logs,temp}
    
    # Initialize agent configuration
    cat > .codex/agent_config.json << 'EOF'
{
    "project_type": "linux_from_scratch_automation",
    "primary_language": "bash",
    "secondary_languages": ["python", "make"],
    "documentation_sources": [
        "docs/lfs/",
        "docs/blfs/", 
        "docs/gaming/"
    ],
    "build_phases": [
        "toolchain",
        "temporary_system", 
        "final_system",
        "blfs_packages",
        "gaming_setup"
    ],
    "target_architectures": ["x86_64", "aarch64"],
    "optimization_level": "balanced",
    "testing_required": true,
    "vm_testing_enabled": true
}
EOF
    
    # Create context prompts for Codex
    cat > .codex/context_prompts.txt << 'EOF'
This is an Auto-LFS-Builder project that automates Linux From Scratch builds.

Key Context:
- Project reads LFS documentation from docs/ folder
- Generates wrapper scripts for build automation  
- Creates self-installing Linux systems
- Supports LFS, BLFS, and Gaming on Linux variants
- Uses modular architecture with builders, parsers, and wrappers
- Requires careful dependency management and build order
- Targets multiple hardware profiles and use cases

When working on this project:
1. Always consider LFS build phases and dependencies
2. Ensure proper error handling for system-critical operations
3. Follow LFS security and verification practices
4. Maintain compatibility across different LFS book versions
5. Test changes in isolated VM environments
6. Document any custom patches or modifications
EOF

    echo "Codex agents initialized successfully!"
}

# =============================================================================
# health_check.sh - System health and readiness check
# =============================================================================

health_check() {
    echo "Running Auto-LFS-Builder health check..."
    
    local errors=0
    
    # Check disk space
    local available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=52428800  # 50GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        echo "ERROR: Insufficient disk space. Need at least 50GB free."
        ((errors++))
    else
        echo "✓ Disk space: OK"
    fi
    
    # Check memory
    local available_memory=$(free -m | awk 'NR==2{print $7}')
    if [ "$available_memory" -lt 4096 ]; then
        echo "WARNING: Less than 4GB available memory. Builds may be slow."
    else
        echo "✓ Memory: OK"
    fi
    
    # Check required tools
    local required_tools=(
        "gcc" "g++" "make" "bison" "flex" "gawk" 
        "texinfo" "patch" "tar" "gzip" "bzip2" 
        "xz" "wget" "curl" "git" "python3"
    )
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "ERROR: Required tool '$tool' not found"
            ((errors++))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        echo "✓ Required tools: OK"
    fi
    
    # Check Python dependencies
    if python3 -c "import requests, lxml, beautifulsoup4" 2>/dev/null; then
        echo "✓ Python dependencies: OK"
    else
        echo "WARNING: Some Python dependencies missing. Run: pip3 install -r requirements.txt"
    fi
    
    # Check virtualization support
    if [ -r /dev/kvm ]; then
        echo "✓ KVM virtualization: Available"
    else
        echo "WARNING: KVM not available. VM testing will be limited."
    fi
    
    # Report results
    if [ $errors -eq 0 ]; then
        echo "Health check PASSED. System ready for LFS builds."
        return 0
    else
        echo "Health check FAILED with $errors errors."
        return 1
    fi
}

# =============================================================================
# monitor_setup.sh - Build monitoring initialization
# =============================================================================

setup_monitoring() {
    echo "Setting up build monitoring..."
    
    # Create monitoring directories
    mkdir -p output/logs/{builds,errors,performance}
    mkdir -p output/metrics
    
    # Initialize build tracking database
    cat > output/metrics/build_tracking.json << 'EOF'
{
    "builds": [],
    "current_build": null,
    "statistics": {
        "total_builds": 0,
        "successful_builds": 0,
        "failed_builds": 0,
        "average_build_time": 0
    }
}
EOF
    
    # Create monitoring script
    cat > tools/build_monitor.sh << 'EOF'
#!/bin/bash
# Real-time build monitoring

monitor_build() {
    local build_id="$1"
    local log_file="output/logs/builds/build-${build_id}.log"
    
    echo "Monitoring build $build_id..."
    echo "Log file: $log_file"
    echo "Press Ctrl+C to stop monitoring"
    
    # Monitor log file and show progress
    tail -f "$log_file" | while read line; do
        case "$line" in
            *"ERROR"*|*"FAILED"*)
                echo -e "\033[31m$line\033[0m"  # Red for errors
                ;;
            *"SUCCESS"*|*"COMPLETED"*)
                echo -e "\033[32m$line\033[0m"  # Green for success
                ;;
            *"WARNING"*)
                echo -e "\033[33m$line\033[0m"  # Yellow for warnings
                ;;
            *)
                echo "$line"
                ;;
        esac
    done
}

# Usage: ./tools/build_monitor.sh <build_id>
monitor_build "$1"
EOF
    
    chmod +x tools/build_monitor.sh
    echo "Build monitoring setup complete!"
}

# =============================================================================
# Main initialization script
# =============================================================================

main() {
    echo "=== Auto-LFS-Builder Initialization ==="
    echo "Starting comprehensive setup..."
    
    # Run setup steps
    setup_lfs_environment
    initialize_codex_agents
    setup_monitoring
    
    echo ""
    echo "Running health check..."
    if health_check; then
        echo ""
        echo "=== Setup Complete ==="
        echo "Auto-LFS-Builder is ready!"
        echo ""
        echo "Next steps:"
        echo "1. Update documentation: ./tools/doc_updater.sh"
        echo "2. Configure build profile: edit config/build_profiles/your_profile.conf"
        echo "3. Start a build: ./src/builders/system_builder.sh --profile minimal"
        echo "4. Monitor progress: ./tools/build_monitor.sh <build_id>"
    else
        echo ""
        echo "=== Setup Issues Detected ==="
        echo "Please resolve the issues above before proceeding."
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
