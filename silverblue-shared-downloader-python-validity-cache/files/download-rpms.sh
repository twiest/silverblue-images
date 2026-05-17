#!/bin/bash

copr_root_path=https://download.copr.fedorainfracloud.org/results/sneexy/python-validity/fedora-44-x86_64

cd "$(dirname ${BASH_SOURCE})"

script_dir=$PWD
rpms_dir=$script_dir/rpms

if [ -d $rpms_dir ]; then
  echo "ERROR: rpms dir already exists [$rpms_dir]"
  exit 10
fi

mkdir "$rpms_dir"
cd "$rpms_dir"

wget $copr_root_path/09643221-python-validity/python3-validity-0.15-1.fc44.noarch.rpm
wget $copr_root_path/09643222-fprintd-clients/fprintd-clients-1.94.5-1.fc44.x86_64.rpm
wget $copr_root_path/09643222-fprintd-clients/fprintd-clients-pam-1.94.5-1.fc44.x86_64.rpm
wget $copr_root_path/09643224-open-fprintd/open-fprintd-0.7-1.fc44.noarch.rpm

echo
echo --------------------------------------------------------------------------------
echo
ls -la --color
echo
