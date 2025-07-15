#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Monitor function
monitor_build() {
    local log_file="/mnt/lfs/Auto-LFS-Builder/logs/build.log"
    local disk_used=0
    local prev_disk_used=0
    local start_time=$(date +%s)

    echo -e "${BLUE}=== Build Monitor Started ===${NC}"
    echo -e "${BLUE}Watching log file: ${log_file}${NC}"
    echo

    while true; do
        # Print recent log entries
        if [[ -f "$log_file" ]]; then
            tail -n 5 "$log_file" | while read -r line; do
                echo -e "$line"
            done
        fi

        # Calculate disk usage
        if [[ -d "/mnt/lfs/Auto-LFS-Builder/workspace" ]]; then
            disk_used=$(du -s "/mnt/lfs/Auto-LFS-Builder/workspace" | cut -f1)
            if [[ $disk_used -ne $prev_disk_used ]]; then
                echo -e "${YELLOW}Disk usage: $(numfmt --to=iec-i --suffix=B $((disk_used*1024)))${NC}"
                prev_disk_used=$disk_used
            fi
        fi

        # Calculate elapsed time
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local hours=$((elapsed / 3600))
        local minutes=$(((elapsed % 3600) / 60))
        local seconds=$((elapsed % 60))

        echo -e "${BLUE}Elapsed time: ${hours}h ${minutes}m ${seconds}s${NC}"
        echo -e "${BLUE}---${NC}"

        sleep 5
        clear
    done
}

# Start monitoring
monitor_build
