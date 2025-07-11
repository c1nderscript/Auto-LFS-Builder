#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 The LFS Automation Team

# Logging utilities for Auto-LFS-Builder

LOG_DIR="${LOG_DIR:-logs}"
mkdir -p "$LOG_DIR"

_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log_info() {
    echo "[INFO  $(_timestamp)] $*"
}

log_success() {
    echo "[OK    $(_timestamp)] $*"
}

log_warning() {
    echo "[WARN  $(_timestamp)] $*" >&2
}

log_error() {
    echo "[ERROR $(_timestamp)] $*" >&2
}

