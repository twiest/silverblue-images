#!/bin/bash

set -eou pipefail

cd "$(dirname $0)"

[ -f "twiest-zfs.pp.bz2" ] && rm twiest-zfs.pp.bz2
[ -f "twiest-zfs.te" ] && rm twiest-zfs.te

cat twiest-zfs---audit.log | audit2allow -M twiest-zfs

bzip2 --keep twiest-zfs.pp
