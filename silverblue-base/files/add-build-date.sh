#!/bin/bash

date_info="/tmp/new_york_date_info.json"
cloud_dir="/etc/cloud"
build_info_file="$cloud_dir/build.info"
worldtimeapi="worldtimeapi.org"

# Make sure we capture the date info. worldtimeapi.org sometimes rejects api calls
while ! curl "http://${worldtimeapi}/api/timezone/America/New_York" > $date_info 2> /dev/null ; do
  echo -n "ERROR: curl failed calling  ${worldtimeapi} at "
  date
  sleep 1
done

build_date=$(jq -r .datetime $date_info | cut -d'T' -f1 | tr -d '-')

echo "Success! Setting build date to [$build_date]"

mkdir -p "$cloud_dir"
echo "distrobox_build_date: $build_date" >> "$build_info_file"
