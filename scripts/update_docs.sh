#!/bin/bash
# Update all documentation repositories and regenerate build scripts when needed.
set -euo pipefail

# Placeholder regeneration function
regenerate_build_scripts() {
    echo "Regenerating build scripts ... (placeholder)"
    # TODO: implement actual generation logic
}

update_documentation() {
    local docs_dirs=("lfs-git" "blfs-git" "jhalfs" "glfs")
    local changed=false

    for repo in "${docs_dirs[@]}"; do
        local path="docs/$repo"
        if [ -d "$path/.git" ]; then
            echo "Updating $path"
            pushd "$path" >/dev/null
            local before=$(git rev-parse HEAD)
            git pull
            local after=$(git rev-parse HEAD)
            if [[ "$before" != "$after" ]]; then
                changed=true
            fi
            popd >/dev/null
        else
            echo "Skipping $path (not a git repo)"
        fi
    done

    if [[ "$changed" == true ]]; then
        echo "Documentation updated, triggering script regeneration"
        regenerate_build_scripts
    fi
}

# Execute function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    update_documentation "$@"
fi
