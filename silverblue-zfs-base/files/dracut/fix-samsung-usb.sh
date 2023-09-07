#!/bin/bash

samsung_drive_name="Samsung  Flash Drive FIT"

set -eou pipefail

for scsiid in $(lsscsi  -v 2>/dev/null | grep -A 1 "$samsung_drive_name" | awk '/\/sys\/devices/ { print $3 }' | tr -d '\[' | tr -d '\]'); do
  for file in $(find "$scsiid" -name provisioning_mode); do
    echo unmap > "$file"
    echo "Fixing $samsung_drive_name: [$scsiid]... Done."
  done
done
