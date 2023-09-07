#!/bin/bash

echo ------------------------------START------------------------------

samsung_drive_name="Samsung  Flash Drive FIT"

set -eou pipefail

echo ------------------------------lsscsi------------------------------
lsscsi  -v 2>/dev/null

echo ------------------------------grep samsung drive------------------------------
lsscsi  -v 2>/dev/null | grep -A 1 "$samsung_drive_name"

echo ------------------------------awk id------------------------------
lsscsi  -v 2>/dev/null | grep -A 1 "$samsung_drive_name" | awk '/\/sys\/devices/ { print $3 }'



echo ------------------------------for------------------------------
for scsiid in $(lsscsi  -v 2>/dev/null | grep -A 1 "$samsung_drive_name" | awk '/\/sys\/devices/ { print $3 }' | tr -d '\[' | tr -d '\]'); do
  echo ------------------------------second for [$scsiid]------------------------------
  for file in $(find "$scsiid" -name provisioning_mode); do
    echo ------------------------------unmap [$file]------------------------------
    echo "before [$file]: $(cat $file)"
    echo unmap > "$file"
    echo "Fixed $samsung_drive_name: [$scsiid]... Done."
    echo "after [$file]: $(cat $file)"
  done
done

echo ------------------------------END------------------------------
