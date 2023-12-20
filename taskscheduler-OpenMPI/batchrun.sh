#!/bin/bash

# Define an array of configurations, each configuration is a string with space-separated values
configurations=(
  # Default configs
  "5 3 5 0.50 tests/dipsy.in"
  "5 2 2 0.00 tests/lala.in"
  "5 2 4 0.50 tests/po.in"
  "12 0 10 0.16 tests/thesun.in"
  "16 1 2 0.10 tests/tinkywinky.in"
  
  # # Vary Generations
  # "2 0 10 0.16 tests/thesun.in"
  # "3 0 10 0.16 tests/thesun.in"
  # "4 0 10 0.16 tests/thesun.in"
  # "5 0 10 0.16 tests/thesun.in"
  # "6 0 10 0.16 tests/thesun.in"
  # "7 0 10 0.16 tests/thesun.in"
  # "8 0 10 0.16 tests/thesun.in"
  # "9 0 10 0.16 tests/thesun.in"
  # "10 0 10 0.16 tests/thesun.in"
  # "11 0 10 0.16 tests/thesun.in"
  # "12 0 10 0.16 tests/thesun.in"

  # # Vary Probability
  # "12 0 10 0.10 tests/thesun.in"
  # "12 0 10 0.11 tests/thesun.in"
  # "12 0 10 0.12 tests/thesun.in"
  # "12 0 10 0.13 tests/thesun.in"
  # "12 0 10 0.14 tests/thesun.in"
  # "12 0 10 0.145 tests/thesun.in"
  # "12 0 10 0.15 tests/thesun.in"
  # "12 0 10 0.155 tests/thesun.in"
  # "12 0 10 0.16 tests/thesun.in"
  # "12 0 10 0.165 tests/thesun.in"
  # "12 0 10 0.17 tests/thesun.in"
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

  sbatch ./config1.sh "${args[@]}"
done
