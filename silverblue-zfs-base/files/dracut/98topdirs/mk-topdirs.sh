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


# Temporarily disable sysroot immutability
/usr/bin/lsattr -d /sysroot
/usr/bin/chattr -V -i /sysroot

IFS=','
for opt in ${value}; do
  top_dir="/sysroot/${opt}"
  echo -n "Creating $top_dir... "
  mkdir -p "$top_dir"
  echo "Done."
done

# Re-enable sysroot immutability
/usr/bin/chattr -V +i /sysroot
/usr/bin/lsattr -d /sysroot
