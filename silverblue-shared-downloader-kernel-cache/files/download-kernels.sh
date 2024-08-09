#!/bin/bash

# Adapted / simplified for my use case from:
#     https://github.com/ublue-os/kernel-cache/tree/main

set -euo pipefail

function determine_kernel_distro_magic() {
  for kernel_patch in $(seq 0 ${kernel_max_patch}); do
    for ix in $(seq ${kernel_max_distro_magic} -1 0); do
      kernel_distro_magic="${ix}00"
      kernel_headers_pkg_base="https://kojipkgs.fedoraproject.org/packages/kernel-headers/${kernel_major}.${kernel_minor}.${kernel_patch}/${kernel_distro_magic}.${kernel_distro}/"
      if curl --head $kernel_headers_pkg_base 2>/dev/null | grep -q '200 OK'; then
        # Successfully determined the distro magic number
        echo $kernel_distro_magic
	return
      fi
    done
  done

  # If it makes it here, it failed
  echo "could not determine kernel_distro_magic number. Last tried [$kernel_headers_pkg_base]"
  return 10
}

function determine_kernel_header_url() {
  for kernel_headers_patch in $(seq ${kernel_max_patch} -1 0); do
    kernel_headers_pkg_base="https://kojipkgs.fedoraproject.org/packages/kernel-headers/${kernel_major}.${kernel_minor}.${kernel_headers_patch}/${kernel_distro_magic}.${kernel_distro}/${kernel_arch}"
    kernel_headers_version=${kernel_major}.${kernel_minor}.${kernel_headers_patch}-${kernel_distro_magic}.${kernel_distro}.${kernel_arch}
    kernel_header_rpm_url="${kernel_headers_pkg_base}/kernel-headers-${kernel_headers_version}.rpm"

    if curl --head $kernel_header_rpm_url 2>/dev/null | grep -q '200 OK'; then
      # Successfully determined the kernel header url
      echo "$kernel_header_rpm_url"
      return
    fi
  done

  # If it makes it here, it failed
  echo "could not find kernel-headers rpm. Last tried [$kernel_header_rpm_url]"
  return 10
}

function determine_kernel_patch_version() {
for kernel_patch in $(seq ${kernel_max_patch} -1 0); do
  kernel_version=${kernel_major}.${kernel_minor}.${kernel_patch}-${kernel_distro_magic}.${kernel_distro}.${kernel_arch}
  kernel_pkg_base="https://kojipkgs.fedoraproject.org/packages/kernel/${kernel_major}.${kernel_minor}.${kernel_patch}/${kernel_distro_magic}.${kernel_distro}/${kernel_arch}"
  pkg=kernel-core

  if curl --head ${kernel_pkg_base}/${pkg}-$kernel_version.rpm 2>/dev/null | grep -q '200 OK'; then
    # Successfully determined the kernel patch version
    echo "$kernel_patch"
    return
  fi
done

  echo "could not find kernel-core rpm"
  return 10
}



####### MAIN #######

# Make the area where the rpms will live
mkdir -p /tmp/rpms
cd /tmp/rpms


# Install ZFS repository
zfs_release_pkg="https://zfsonlinux.org/fedora/zfs-release-2-5$(rpm --eval "%{dist}").noarch.rpm"
dnf install -y "${zfs_release_pkg}"

# Download zfs-dkm and the zfs-release. The zfs-release rpm will be saved in the image.
dnf download -y zfs-dkms "${zfs_release_pkg}"

ls -la


echo
echo --------------------------------------------------------------------------------
echo -n "Determining what's the highest kernel version that zfs-dkms supports... "
kernel_release=$(rpm -qp --requires zfs-dkms-*.rpm 2>/dev/null | awk '/kernel-devel <= / { blah = $3 } END { print blah }')
rm zfs-dkms-*.rpm
echo "success! [$kernel_release]"

kernel_arch=x86_64
kernel_major=$(echo "$kernel_release" | cut -d '.' -f 1)
kernel_minor=$(echo "$kernel_release" | cut -d '.' -f 2)
kernel_max_patch=30
kernel_max_distro_magic=5
kernel_distro=fc40
max_kernel_headers_patch=25


echo
echo --------------------------------------------------------------------------------
echo -n "Determining kernel_distro_magic number... "
kernel_distro_magic=$(determine_kernel_distro_magic)
retval=$?

if [ $retval -ne 0 ]; then
  echo "FAILED: $kernel_distro_magic"
  exit $retval
fi

echo "success! [$kernel_distro_magic]"

echo
echo --------------------------------------------------------------------------------
echo -n "Determining what the highest compatible kernel-headers patch level is... "

kernel_header_rpm_url=$(determine_kernel_header_url)
retval=$?

if [ $retval -ne 0 ]; then
  echo "FAILED: $kernel_header_rpm_url"
  exit $retval
fi

echo "success!"
echo "Running: dnf download -y $kernel_header_rpm_url"
dnf download -y $kernel_header_rpm_url

echo
echo --------------------------------------------------------------------------------
echo -n "Determining what the highest compatible kernel patch level is... "

kernel_patch=$(determine_kernel_patch_version)
retval=$?

if [ $retval -ne 0 ]; then
  echo "FAILED: $kernel_patch"
  exit $retval
fi

echo "success! [$kernel_patch]"

echo
echo --------------------------------------------------------------------------------
echo "Kernel Version Variables"
echo

kernel_version=${kernel_major}.${kernel_minor}.${kernel_patch}-${kernel_distro_magic}.${kernel_distro}.${kernel_arch}

echo kernel_major: $kernel_major
echo kernel_minor: $kernel_minor
echo kernel_patch: $kernel_patch
echo kernel_distro_magic: $kernel_distro_magic
echo kernel_distro: $kernel_distro
echo kernel_arch: $kernel_arch
echo kernel_max_patch: $kernel_max_patch
echo kernel_version: $kernel_version

echo
echo --------------------------------------------------------------------------------
echo "Downloading ZFS compatible kernels"
echo
kernel_pkg_base="https://kojipkgs.fedoraproject.org/packages/kernel/${kernel_major}.${kernel_minor}.${kernel_patch}/${kernel_distro_magic}.${kernel_distro}/${kernel_arch}"
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-devel kernel-devel-matched kernel-uki-virt ; do
  echo "Running: dnf download -y ${kernel_pkg_base}/${pkg}-$kernel_version.rpm"
  dnf download -y "${kernel_pkg_base}/${pkg}-$kernel_version.rpm"
  echo
done




echo
echo --------------------------------------------------------------------------------
echo
echo Results:
echo
pwd
ls -la --color
echo
echo --------------------------------------------------------------------------------
