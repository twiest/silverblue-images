#!/usr/bin/env xonsh

source /usr/local/lib/xonsh/colors.xsh

script_dir = $(dirname @($ARGS[0]))
script_name = $(basename @($ARGS[0]))
distro = $(basename $(dirname $PWD))

cd @(script_dir)

img_name = $(basename $PWD)
date_stamp = $(date +%Y-%m-%d)

# MUST use "--format docker" because the FROM container images has a HEALTHCHECK. Otherwise I get this warning:
#      WARN[0138] HEALTHCHECK is not supported for OCI image format and will be ignored. Must use `docker` format
time -p podman build --format docker @($ARGS[1:]) . -t f"{ img_name }:{ date_stamp }" -t f"{ img_name }:latest" -t f"ghcr.io/twiest/{ img_name }:latest"
