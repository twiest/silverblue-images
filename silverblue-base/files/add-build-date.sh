#!/bin/bash

date_info="/tmp/gmt_date_info"
cloud_dir="/etc/cloud"
build_info_file="$cloud_dir/build.info"
datetime_url="https://google.com"

# Make sure we capture the date info. worldtimeapi.org sometimes rejects api calls
while ! curl -sI "$datetime_url" | awk '/^date:/ { $1=""; print $0 }' > $date_info 2> /dev/null ; do
  echo -n "ERROR: curl failed calling  ${datetime_url} at "
  date
  sleep 1
done

build_date=$(date -d "$(cat $date_info)" +%Y-%m-%d)

echo "Success! Setting build date to [$build_date]"

mkdir -p "$cloud_dir"
echo "distrobox_build_date: $build_date" >> "$build_info_file"
