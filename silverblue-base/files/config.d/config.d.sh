#!/bin/bash

configd_dir=/etc/config.d

mkdir -p "$configd_dir"

echo "Running config.d scripts:"
for script in $(ls "$configd_dir"); do
  echo "    Running [$script]"

  # Run the script and pre-pend padding so that it looks good in journald
  bash "${configd_dir}/${script}" | sed 's/^/        /'
done