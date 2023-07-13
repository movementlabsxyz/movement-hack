#!/bin/bash
set -e

# Define the directory to search
root_dir="./examples"

# Find all subdirectories within the root directory
find "$root_dir" -type d | while read -r dir; do
  # Get the inner directory name
  inner_dir=$(basename "$dir")
  
  # Check if the subdirectory contains ./bin/citest.sh
  if [ -f "$dir/bin/citest.sh" ]; then
    echo "Running ./bin/citest.sh in $dir"
    # Change to the inner directory and run the script
    (cd "$dir" && ./bin/citest.sh)
  fi
done