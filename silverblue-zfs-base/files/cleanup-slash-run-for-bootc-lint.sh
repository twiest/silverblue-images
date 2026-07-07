#!/bin/bash

set -euo pipefail

target=/run

cd "$target"

for item in *; do
    # Check if the item exists (handles empty directories)
    [ -e "$item" ] || continue

    case "$item" in
        "secrets"|"systemd")
            echo "Skipping: ${target}/${item}"
            ;;
        *)
            echo "Removing: ${target}/${item}"
            # Use rm -rf for directories and files
            rm -rf "$item"
            ;;
    esac
done
