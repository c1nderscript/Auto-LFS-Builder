#!/bin/bash
# Common logging functions

_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log_info() {
    echo "[INFO $( _timestamp )] $*"
}

log_success() {
    echo "[SUCCESS $( _timestamp )] $*"
}

log_error() {
    echo "[ERROR $( _timestamp )] $*" >&2
}

log_warn() {
    echo "[WARN $( _timestamp )] $*"
}
