#!/bin/bash

# Change the script dir
cd $(dirname -- ${BASH_SOURCE[0]})

image=$(awk '/FROM.*quay.io/ { print $2 }' ../../Containerfile)
#FROM quay.io/fedora/fedora-silverblue:40

podman run -it --rm -v $PWD:/build:z "$image" /build/in-ctr-build.sh
