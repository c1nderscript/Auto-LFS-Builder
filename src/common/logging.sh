#!/bin/bash
# Logging utility functions

LOG_DIR="${LOG_DIR:-logs}"
mkdir -p "$LOG_DIR"

_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log_info() {
    echo "$( _timestamp ) [INFO] $*"
}

log_warning() {
    echo "$( _timestamp ) [WARN] $*" >&2
}

log_error() {
    echo "$( _timestamp ) [ERROR] $*" >&2
}

log_success() {
    echo "$( _timestamp ) [SUCCESS] $*"
}
