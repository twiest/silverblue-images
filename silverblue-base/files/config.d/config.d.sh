#!/bin/bash

configd_dirs="/etc/config.d /usr/local/etc/config.d/all /usr/local/etc/config.d/$(hostname)"

script_exit_code=0
for configd_dir in $configd_dirs; do
  if [ ! -d "$configd_dir" ]; then
    echo "Skipping [$configd_dir]... directory doesn't exist."
    continue
  fi

  echo "Running $configd_dir scripts:"
  for curfile in $(ls "$configd_dir"); do
    script="${configd_dir}/${curfile}"
    if [ -d "$script" ]; then
      continue
    fi

    if [ ! -x "$script" ]; then
      echo "    Skipping [$script]... not executable"
      continue
    fi

    echo "    Running [$script]"

    # Run the script and pre-pend padding so that it looks good in journald
    /usr/bin/time -p bash -c "${script} 2>&1" 2>&1 | sed 's/^/        /'
    retval=${PIPESTATUS[0]}

    if [ $retval != 0 ]; then
      script_exit_code=$retval
    fi
  done
done

exit $script_exit_code
