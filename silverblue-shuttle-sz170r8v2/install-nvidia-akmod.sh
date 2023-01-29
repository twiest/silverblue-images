#!/bin/bash

mkdir -p /var/log/akmods /var/tmp /run/akmods
chmod --reference=/tmp /var/tmp

[ -f /usr/bin/ld ] || ln -s /usr/bin/ld.bfd /usr/bin/ld

/usr/sbin/akmods --force --kernels "$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

[ -h /usr/bin/ld ] && rm /usr/bin/ld
rm -rf /var/log/akmods/ /var/tmp /run/akmods/
