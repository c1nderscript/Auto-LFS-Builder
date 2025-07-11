#!/usr/bin/env bash
# Validate environment for Auto-LFS-Builder

set -e

PROFILE_FILE=${1:-config/build_profiles/default.conf}

if [ ! -f "$PROFILE_FILE" ]; then
    echo "Profile file not found: $PROFILE_FILE" >&2
    exit 1
fi

# shellcheck source=/dev/null
source "$PROFILE_FILE"

# Default docs root if not provided by profile
DOCS_ROOT=${DOCS_ROOT:-"$(dirname "$(readlink -f "$0")")/../docs"}

validate_environment() {
    local required_tools=(
        bash gcc g++ make bison flex gawk
        texinfo patch tar gzip bzip2 xz
        wget curl git python3 xmllint pandoc
    )

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "ERROR: Required tool '$tool' not found" >&2
            return 1
        fi
    done

    echo "All required tools are available"
    return 0
}

check_environment_health() {
    local available_space
    available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=52428800  # 50GB in KB

    if [ "$available_space" -lt "$required_space" ]; then
        echo "WARNING: Insufficient disk space" >&2
    fi

    local available_memory
    available_memory=$(free -m | awk 'NR==2{print $7}')
    if [ "$available_memory" -lt 4096 ]; then
        echo "WARNING: Less than 4GB available memory" >&2
    fi

    if [ ! -d "$DOCS_ROOT" ]; then
        echo "ERROR: Documentation directory not found: $DOCS_ROOT" >&2
        return 1
    fi

    echo "Environment health check passed"
    return 0
}

validate_environment && check_environment_health
