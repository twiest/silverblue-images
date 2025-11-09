#!/bin/bash

set -euo pipefail

cd "$(dirname -- ${BASH_SOURCE[0]})"
script_dir=$PWD
previous_release_dir=${script_dir%-next}
script_name=$(basename ${BASH_SOURCE[0]})


function remove_copied_files_and_dirs() {
  # Remove all files in the current directory and its subdirectories
  echo "Removing extra dirs: START"
  rm -v -rf "$(realpath files)"
  echo "Removing extra dirs: DONE"

  echo "Removing extra files: START"
  find . -type f ! -name "*.swp" ! -name "$script_name" -print0 | while IFS= read -r -d $'\0' file_relative_path; do
    file=$(realpath "$file_relative_path")

    # Double check that the file is indeed below the script directory
    if [[ "$file" == "$script_dir"* ]]; then
      rm -v "$file"
    fi
  done
  echo "Removing extra files: DONE"
  echo
}

function copy_files_from_previous_release() {
  echo "Copying files from previous release: START"
  rsync -va "${previous_release_dir}/" .
  echo "Copying files from previous release: DONE"
}

remove_copied_files_and_dirs
copy_files_from_previous_release
