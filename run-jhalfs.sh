#!/bin/bash
set -euo pipefail
cd /opt/jhalfs
exec ./jhalfs "$@"
