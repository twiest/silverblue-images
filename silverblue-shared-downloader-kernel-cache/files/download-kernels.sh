#!/bin/bash

# Adapted / simplified for my use case from:
#     https://github.com/ublue-os/kernel-cache/tree/main

set -euo pipefail

dnf download -y zfs-dkms

kernel_release=$(rpm -qp --requires zfs-dkms-*.rpm 2>/dev/null | awk '/kernel-devel <= / { blah = $3 } END { print blah }')
rm zfs-dkms-*.rpm

mkdir -p /tmp/rpms
cd /tmp/rpms
kernel_arch=x86_64
kernel_major=$(echo "$kernel_release" | cut -d '.' -f 1)
kernel_minor=$(echo "$kernel_release" | cut -d '.' -f 2)
kernel_max_patch=30
kernel_distro_magic=300
kernel_distro=fc40
max_kernel_headers_patch=25


echo --------------------------------------------------------------------------------
echo -n "Determining what the highest compatible kernel-headers patch level is... "
for kernel_headers_patch in $(seq ${kernel_max_patch} -1 0); do
  kernel_headers_pkg_base="https://kojipkgs.fedoraproject.org/packages/kernel-headers/${kernel_major}.${kernel_minor}.${kernel_headers_patch}/${kernel_distro_magic}.${kernel_distro}/${kernel_arch}"
  kernel_headers_version=${kernel_major}.${kernel_minor}.${kernel_headers_patch}-${kernel_distro_magic}.${kernel_distro}.${kernel_arch}
  kernel_header_rpm_url="${kernel_headers_pkg_base}/kernel-headers-${kernel_headers_version}.rpm"

  if curl --head $kernel_header_rpm_url 2>/dev/null | grep -q '200 OK'; then
    echo "success!"
    echo "Running: dnf download -y $kernel_header_rpm_url"
    dnf download -y $kernel_header_rpm_url
    break # We found it
  fi
done

if [ $kernel_headers_patch -eq 0 ]; then
  echo "FAILED: could not find kernel-core rpm"
  exit 10
fi


echo --------------------------------------------------------------------------------
echo -n "Determining what the highest compatible kernel patch level is... "
for kernel_patch in $(seq ${kernel_max_patch} -1 0); do
  kernel_version=${kernel_major}.${kernel_minor}.${kernel_patch}-${kernel_distro_magic}.${kernel_distro}.${kernel_arch}
  kernel_pkg_base="https://kojipkgs.fedoraproject.org/packages/kernel/${kernel_major}.${kernel_minor}.${kernel_patch}/${kernel_distro_magic}.${kernel_distro}/${kernel_arch}"
  pkg=kernel-core

  if curl --head ${kernel_pkg_base}/${pkg}-$kernel_version.rpm 2>/dev/null | grep -q '200 OK'; then
    break # We found it, leave the loop
  fi
done

if [ $kernel_patch -eq 0 ]; then
  echo "FAILED: could not find kernel-core rpm"
  exit 10
fi

echo "success!"

kernel_version=${kernel_major}.${kernel_minor}.${kernel_patch}-${kernel_distro_magic}.${kernel_distro}.${kernel_arch}
kernel_pkg_base="https://kojipkgs.fedoraproject.org/packages/kernel/${kernel_major}.${kernel_minor}.${kernel_patch}/${kernel_distro_magic}.${kernel_distro}/${kernel_arch}"

if [ $# -gt 0 ] && [ "$1" == "--debug" ]; then
    echo kernel_major: $kernel_major
    echo kernel_minor: $kernel_minor
    echo kernel_patch: $kernel_patch
    echo kernel_distro_magic: $kernel_distro_magic
    echo kernel_distro: $kernel_distro
    echo kernel_arch: $kernel_arch
    echo kernel_max_patch: $kernel_max_patch
    echo kernel_version: $kernel_version
fi

for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-devel kernel-devel-matched kernel-uki-virt ; do
  echo "Running: dnf download -y ${kernel_pkg_base}/${pkg}-$kernel_version.rpm"
  dnf download -y "${kernel_pkg_base}/${pkg}-$kernel_version.rpm"
  echo
done




echo --------------------------------------------------------------------------------
echo
echo Results:
echo
pwd
ls -la --color
echo
echo --------------------------------------------------------------------------------
