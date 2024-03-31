#!/bin/bash

configd_dirs="/etc/config.d /usr/local/etc/config.d /usr/local/etc/$(hostname)/config.d"

for configd_dir in $configd_dirs; do
  if [ ! -d "$configd_dir" ]; then
    echo "Skipping $configd_dir"
    continue
  fi

  echo "Running $configd_dir scripts:"
  for script in $(ls "$configd_dir"); do
    echo "    Running [$script]"

    # Run the script and pre-pend padding so that it looks good in journald
    bash "${configd_dir}/${script}" | sed 's/^/        /'
  done
done
