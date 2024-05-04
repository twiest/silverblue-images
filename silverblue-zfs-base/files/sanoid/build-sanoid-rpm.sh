#!/bin/bash

# Change the script dir
cd $(dirname -- ${BASH_SOURCE[0]})

image=$(awk '/FROM/ { print $2 }' ../../Containerfile)

podman run -it --rm -v $PWD:/build:z "$image" /build/in-ctr-build.sh
