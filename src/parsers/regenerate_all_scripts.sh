#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Regenerate all build scripts by parsing documentation
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

ensure_directories() {
    mkdir -p generated || handle_error "Failed to create generated directory"
    mkdir -p logs/parsing_logs || handle_error "Failed to create parsing logs directory"
}

run_parsers() {
    log_info "Merging documentation sources"
    python3 src/parsers/documentation_merger.py > logs/parsing_logs/documentation_merger.log 2>&1 \
        || handle_error "Documentation merge failed"

    log_info "Parsing LFS documentation"
    python3 src/parsers/lfs_parser.py > logs/parsing_logs/lfs_parser.log 2>&1 \
        || handle_error "LFS parsing failed"

    log_info "Resolving package dependencies"
    python3 src/parsers/dependency_resolver.py > logs/parsing_logs/dependency_resolver.log 2>&1 \
        || handle_error "Dependency resolution failed"

    log_info "Analyzing package requirements"
    python3 src/parsers/package_analyzer.py > logs/parsing_logs/package_analyzer.log 2>&1 \
        || handle_error "Package analysis failed"
}

main() {
    log_info "Regenerating build scripts"
    ensure_directories
    run_parsers
    log_success "Build script regeneration complete"
}

main "$@"
