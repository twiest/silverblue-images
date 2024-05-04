#!/bin/bash

set -euo pipefail

sanoid_version=sanoid-2.2.0

mkdir -p /var/roothome
mkdir -p /root/rpmbuild/RPMS/noarch
mkdir -p /root/rpmbuild/SOURCES
mkdir -p /root/rpmbuild/SPECS
mkdir -p /root/rpmbuild/SRPMS

cd /root/
tar -zxvf /build/${sanoid_version}.tar.gz

rpm-ostree install -y rpm-build

cp /build/${sanoid_version}.tar.gz /root/rpmbuild/SOURCES/${sanoid_version}.tar.gz

rpmbuild --target noarch -bb /root/${sanoid_version}/packages/rhel/sanoid.spec

echo
cp -v /root/rpmbuild/RPMS/noarch/${sanoid_version}*.rpm /build
echo
echo "Completed Successfully!"
