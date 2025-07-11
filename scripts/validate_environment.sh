#!/bin/bash
# Auto-LFS-Builder Environment Validation Script

# Validate required tools are present
validate_environment() {
    local required_tools=(
        "bash" "gcc" "g++" "make" "bison" "flex" "gawk"
        "texinfo" "patch" "tar" "gzip" "bzip2" "xz"
        "wget" "curl" "git" "python3" "xmllint" "pandoc"
    )

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "ERROR: Required tool '$tool' not found" >&2
            return 1
        fi
    done

    echo "All required tools are available"
    return 0
}

# Check environment configuration and available resources
check_environment_health() {
    # Check disk space
    local available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=52428800  # 50GB in KB

    if [ "$available_space" -lt "$required_space" ]; then
        echo "WARNING: Insufficient disk space" >&2
    fi

    # Check memory
    local available_memory=$(free -m | awk 'NR==2{print $7}')
    if [ "$available_memory" -lt 4096 ]; then
        echo "WARNING: Less than 4GB available memory" >&2
    fi

    # Check documentation directory
    if [ ! -d "$DOCS_ROOT" ]; then
        echo "ERROR: Documentation directory not found: $DOCS_ROOT" >&2
        return 1
    fi

    echo "Environment health check passed"
    return 0
}

usage() {
    echo "Usage: $0 [validate|health|all]" >&2
    echo "  validate   Run validate_environment" >&2
    echo "  health     Run check_environment_health" >&2
    echo "  all (default) Run both checks" >&2
}

main() {
    local action=${1:-all}
    case "$action" in
        validate)
            validate_environment
            ;;
        health)
            check_environment_health
            ;;
        all)
            validate_environment && check_environment_health
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
