#!/bin/bash
# Common error handling

handle_error() {
    local message="$1"
    log_error "$message"
    exit 1
}

