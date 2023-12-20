#!/bin/bash

# Define an array of configurations, each configuration is a string with space-separated values
configurations=(
  "12 0 10 0.135 tests/thesun.in"
  "12 0 10 0.145 tests/thesun.in"
  "12 0 10 0.155 tests/thesun.in"
  "12 0 10 0.165 tests/thesun.in"
)

# Loop over configurations
for config in "${configurations[@]}"; do
  # Split the configuration into individual arguments
  IFS=' ' read -r -a args <<< "$config"

  # Perform the original tasks with the arguments
  arg1=${args[0]}
  arg2=${args[1]}
  arg3=${args[2]}
  arg4=${args[3]}
  arg5=${args[4]}
  output_file="${arg5%.*}_${arg1}_${arg2}_${arg3}_${arg4}.out"
  echo "Putting output in file $output_file"

  set -x

  EVALUATE=0 SEQ=1 sbatch --nodes 1 --ntasks 1 --time 00:20:00 --partition xw-2245 --constraint xw-2245 -o $output_file -e $output_file config1.sh "${args[@]}"
done
