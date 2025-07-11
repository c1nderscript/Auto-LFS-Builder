#!/bin/bash
# Regenerate All Scripts: Parse documentation and regenerate build scripts
# Dependencies: documentation_merger.py, dependency_resolver.py, lfs_parser.py

set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

DOCS_ROOT="docs"
OUTPUT_DIR="generated"

parse_documentation() {
    log_info "Parsing documentation from ${DOCS_ROOT}"
    python3 src/parsers/documentation_merger.py "${DOCS_ROOT}" \
        || handle_error "Documentation parsing failed"
}

resolve_dependencies() {
    log_info "Resolving package dependencies"
    python3 src/parsers/dependency_resolver.py "${DOCS_ROOT}" > "${OUTPUT_DIR}/dependencies.json" \
        || handle_error "Dependency resolution failed"
}

generate_scripts() {
    log_info "Generating build scripts"
    python3 src/parsers/lfs_parser.py "${DOCS_ROOT}" > "${OUTPUT_DIR}/complete_build.sh" \
        || handle_error "Build script generation failed"
    chmod +x "${OUTPUT_DIR}/complete_build.sh" \
        || handle_error "Failed to set executable permissions on complete_build.sh"
}

main() {
    mkdir -p "${OUTPUT_DIR}" || handle_error "Unable to create output directory"
    parse_documentation
    resolve_dependencies
    generate_scripts
    log_success "All scripts regenerated successfully"
}

main "$@"
