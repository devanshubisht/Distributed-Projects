#!/bin/bash
#SBATCH --job-name=DevMent
#SBATCH --nodes=5
#SBATCH --nodelist=soctf-pdc-008,soctf-pdc-016,soctf-pdc-019,soctf-pdc-021,soctf-pdc-024
#SBATCH --mem=1gb
#SBATCH --time=02:00:00
#SBATCH --output=result.log
#SBATCH --error=result.log

# Array of hostnames
declare -a hosts=("soctf-pdc-008" "soctf-pdc-016" "soctf-pdc-019" "soctf-pdc-021" "soctf-pdc-024")

# Array of ADD_THREADS and SUB_THREADS values
declare -a thread_counts=(4 8 16 32 64)

# Compile the program
echo "Compiling..."
make build

# Loop over all hostnames
for host in "${hosts[@]}"
do
  # Loop over different test input files
  for test_file in ./test/test_g100000_r50_c60_i200.in ./test/test_g100000_r80_c90_i200.in ./test/test_g100000_r30_c40_i200.in ./test/test_g100000_r100_c30_i200.in ./test/test_g100000_r30_c100_i200.in ./test/test_g100000_r50_c60_i200.in ./test/test_g100000_r50_c60_i300.in ./test/test_g100000_r50_c60_i400.in
  do

    # Run the matrix multiplication program with perf, requesting statistics on
    # instructions, cycles, and flops
    srun -N 1 -n 1 -w $host perf stat -e cycles,instructions,L1-dcache-load-misses,L1-dcache-loads ./iom_sequential "$test_file" test.out 1

    # Loop over all thread_counts for iom_cpp.out
    for thread_count in "${thread_counts[@]}"
    do
      srun -N 1 -n 1 -w $host echo "Running on $host with $thread_count threads."

      # Run the iom_cpp.out program with perf for each thread count
      srun -N 1 -n 1 -w $host perf stat -e cycles,instructions,L1-dcache-load-misses,L1-dcache-loads ./iom_cpp.out "$test_file" test.out $thread_count
    done
  done
done
