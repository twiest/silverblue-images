#!/bin/bash

set -euo pipefail

mkdir -p /var/log/akmods /var/tmp /run/akmods
# Set the perms so akmods can build
chmod 777 /tmp /var/tmp

# TODO: Remove the following line once this bug is fixed: https://github.com/coreos/rpm-ostree/issues/4201
[ -f /usr/bin/ld ] || ln -s /usr/bin/ld.bfd /usr/bin/ld

kernel_version="$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
/usr/sbin/akmods --force --kernels "$kernel_version"

# Set the perms back
chmod 755 /tmp /var/tmp

if [ -d "/lib/modules/${kernel_version}/extra/nvidia" ]; then
  echo
  echo "nvidia akmod build succeeded!"
  echo
else
  echo "ERROR: nvidia akmod failed to build!"
  exit 10
fi

[ -h /usr/bin/ld ] && rm /usr/bin/ld
rm -rf /var/log/akmods/ /var/tmp /run/akmods/
