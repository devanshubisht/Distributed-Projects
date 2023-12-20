#!/bin/bash

# Define the maximum values for each variable
declare -a nGenerations=(100000 100000 100000 100000 100000 100000)
declare -a row=(50 50 50 50 50 50)
declare -a col=(60 60 60 60 60 60)
declare -a nInvasions=(200 800 1200 1600 2000 2400)

# Generate test inputs
for ((i=0; i<${#row[@]}; i++)); do
    python3 gen.py --n_generations ${nGenerations[$i]} --n_rows ${row[$i]} --m_cols ${col[$i]} --nInvasions ${nInvasions[$i]} --output_file "test_g${nGenerations[$i]}_r${row[$i]}_c${col[$i]}_i${nInvasions[$i]}.in"
done
