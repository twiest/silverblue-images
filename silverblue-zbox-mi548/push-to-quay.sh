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

podman push "quay.io/thwiest/$IMGNAME:latest"
podman push "quay.io/thwiest/$IMGNAME:${DATESTAMP}"
