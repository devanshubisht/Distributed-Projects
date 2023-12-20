#!/bin/bash
#SBATCH --job-name=DevMent
#SBATCH --nodes=1
#SBATCH --nodelist=soctf-pdc-007
#SBATCH --mem=1gb
#SBATCH --time=02:00:00
#SBATCH --output=resultGeneration7k+.log
#SBATCH --error=resultGeneration7k+.log

# Array of hostnames
declare -a hosts=("soctf-pdc-007")

# Array of ADD_THREADS and SUB_THREADS values
declare -a thread_counts=(1 4 8 16 32 64)

# Compile the program
echo "Compiling..."
make build

# Loop over all hostnames
for host in "${hosts[@]}"
do
  # Loop over different test input files
  for test_file in ./test/test_g70000_r50_c60_i200.in ./test/test_g80000_r50_c60_i200.in ./test/test_g90000_r50_c60_i200.in ./test/test_g100000_r50_c60_i200.in
  do

    for thread_count in "${thread_counts[@]}"
    do
      srun -N 1 -n 1 -w $host echo "Running on $host with $thread_count threads."

      # Run the iom_cpp.out program with perf for each thread count
      srun -N 1 -n 1 -w $host perf stat -e cycles,instructions,L1-dcache-load-misses,L1-dcache-loads ./iom_cpp.out "$test_file" test.out $thread_count
    done

  done
done
