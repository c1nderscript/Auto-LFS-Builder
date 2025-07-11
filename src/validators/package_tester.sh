#!/bin/bash
# Package Tester: Test individual packages
set -euo pipefail

source src/common/logging.sh
source src/common/error_handling.sh
source src/common/package_management.sh

test_package() {
    local pkg="$1"
    log_info "Running tests for $pkg" || true
    if [ -d "$pkg" ]; then
        pushd "$pkg" > /dev/null || handle_error "enter $pkg"
        make check || handle_error "tests failed for $pkg"
        popd > /dev/null || handle_error "leave $pkg"
    else
        handle_error "package directory $pkg not found"
    fi
}

main() {
    log_info "Testing packages"
    test_package "$@"
    log_success "Package testing complete"
}

main "$@"
