#!/usr/bin/env xonsh

import sys

$XONSH_SHOW_TRACEBACK = True

script_dir = $(realpath $(dirname @($ARGS[0]))).strip()

cd @(script_dir)

img_name = $(basename $PWD).strip()
date_stamp = $(date +%Y-%m-%d).strip()

# MUST use "--format docker" because the FROM container images has a HEALTHCHECK. Otherwise I get this warning:
#      WARN[0138] HEALTHCHECK is not supported for OCI image format and will be ignored. Must use `docker` format

result = None
for i in range(1, 4):
    echo
    echo --------------------------------------------------------------------------------
    echo -n f"Build Attempt { i }/3 - "
    date
    echo
    result = ![time -p podman build --format docker @($ARGS[1:]) . -t f"{ img_name }:{ date_stamp }" -t f"{ img_name }:latest" -t f"ghcr.io/twiest/{ img_name }:latest"]
    if result.returncode == 0:
        break

# Return with same returncode as the build
sys.exit(result.returncode)
