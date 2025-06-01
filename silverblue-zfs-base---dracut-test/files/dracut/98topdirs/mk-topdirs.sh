#!/bin/bash

# To add a dir to the top of the filesystem (aka the root or /), run something like:
# rpm-ostree kargs --append-if-missing=topdirs=dir1,dir2


set -euo pipefail

kernel_cmdline="$(cat /proc/cmdline)"

# xargs chomps the whitespace
set +o pipefail
option_raw=$(echo $kernel_cmdline | grep -o -E '(^|\s)topdirs=\S+' | xargs)
set -o pipefail

if [ -z "$option_raw" ]; then
  echo "topdirs option not found in /proc/cmdline"
  exit 0
fi

save_ifs=$IFS
IFS='='
read -a options_kv <<< "$option_raw"
IFS=$save_ifs

key="${options_kv[0]}"
value="${options_kv[1]}"


sysroot_base_dir=/sysroot/sysroot

# Temporarily disable sysroot immutability
mount -o remount,rw "$sysroot_base_dir"

IFS=','
for opt in ${value}; do
  top_dir="${sysroot_base_dir}/${opt}"
  echo -n "Creating $top_dir... "
  mkdir -p "$top_dir"
  echo "Done."
done

# Re-enable sysroot immutability
mount -o remount,ro "$sysroot_base_dir"
