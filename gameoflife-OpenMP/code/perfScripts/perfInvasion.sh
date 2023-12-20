#!/bin/bash
#SBATCH --job-name=DevMent
#SBATCH --nodes=1
#SBATCH --nodelist=soctf-pdc-007
#SBATCH --mem=1gb
#SBATCH --time=02:00:00
#SBATCH --output=resultInvasion.log
#SBATCH --error=resultInvasion.log

# Array of hostnames
declare -a hosts=("soctf-pdc-007")

# Array of ADD_THREADS and SUB_THREADS values
declare -a thread_counts=(8)

# Compile the program
echo "Compiling..."
make build

# Loop over all hostnames
for host in "${hosts[@]}"
do
  # Loop over different test input files
  for test_file in ./test/test_g100000_r50_c60_i400.in ./test/test_g100000_r50_c60_i800.in ./test/test_g100000_r50_c60_i1200.in ./test/test_g100000_r50_c60_i1600.in ./test/test_g100000_r50_c60_i2000.in ./test/test_g100000_r50_c60_i2400.in
  do

    # Run the matrix multiplication program with perf, requesting statistics on
    # instructions, cycles, and flops
    srun -N 1 -n 1 -w $host perf stat -e cycles,instructions,L1-dcache-load-misses,L1-dcache-loads ./iom_cpp.out "$test_file" test.out 8

  done
done
