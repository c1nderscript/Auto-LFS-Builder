#!/bin/bash
set -euo pipefail

for script in src/builders/*.sh; do
    bash -n "$script"
    bash "$script" >/dev/null
done

echo "Builder scripts executed successfully"
