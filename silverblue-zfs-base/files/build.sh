#!/bin/bash

set -eou pipefail

cd "$(dirname $0)"

[ -f "twiest-zfs-snapshot-mount.pp.bz2" ] && rm twiest-zfs-snapshot-mount.pp.bz2
[ -f "twiest-zfs-snapshot-mount.te" ] && rm twiest-zfs-snapshot-mount.te

cat twiest-zfs-snapshot-mount---audit.log | audit2allow -M twiest-zfs-snapshot-mount

bzip2 twiest-zfs-snapshot-mount.pp
