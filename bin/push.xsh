#!/usr/bin/env xonsh

import sys

max_retries = 100

$XONSH_SHOW_TRACEBACK = True

script_dir = $(realpath $(dirname @($ARGS[0]))).strip()

cd @(script_dir)

img_name = $(basename $PWD).strip()

result = None
for i in range(1, max_retries + 1):
    echo
    echo --------------------------------------------------------------------------------
    echo -n f"Attempt { i }/{ max_retries } - "
    date
    echo
    result = ![time -p podman push f"ghcr.io/twiest/{ img_name }:latest"]
    if result.returncode == 0:
        break

    echo "Sleeping 10 seconds before next retry... "
    sleep 10

# Return with same returncode as the cmd
sys.exit(result.returncode)
