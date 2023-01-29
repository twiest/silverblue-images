#!/bin/bash

mkdir -p /var/log/akmods /var/tmp /run/akmods
chmod --reference=/tmp /var/tmp

# TODO: Remove the following line once this bug is fixed: https://github.com/coreos/rpm-ostree/issues/4201
[ -f /usr/bin/ld ] || ln -s /usr/bin/ld.bfd /usr/bin/ld

/usr/sbin/akmods --force --kernels "$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

[ -h /usr/bin/ld ] && rm /usr/bin/ld
rm -rf /var/log/akmods/ /var/tmp /run/akmods/
