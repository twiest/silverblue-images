#!/bin/bash

RED='\033[0;31m'
NO_COLOR='\033[0m'

set -euo pipefail


err_report() {
    echo
    echo
    echo -e "${RED}Error $1 occured on line $2${NO_COLOR}"
    echo
    exit $1
}

trap 'err_report $? $LINENO' ERR

cd $(dirname $0)

IMGNAME=$(basename $PWD)
DATESTAMP=$(date +%Y-%m-%d)

build_rpms_image="${IMGNAME}:build_rpms"
time podman build $@ -f Containerfile.build_rpms -t "${build_rpms_image}"

ctr_id=$(podman create "${build_rpms_image}")
rpms_dir="$PWD/files/rpms"
if [ -d "$rpms_dir" ]; then
  mv "${rpms_dir}" "${rpms_dir}-pre-${DATESTAMP}"
fi

podman cp "${ctr_id}:/rpms" "${rpms_dir}"

podman rm "${ctr_id}"

time podman build $@ . -t "${IMGNAME}:${DATESTAMP}" -t "${IMGNAME}:latest" -t "ghcr.io/twiest/${IMGNAME}:latest"
