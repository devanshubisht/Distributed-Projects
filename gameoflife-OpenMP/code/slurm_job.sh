#!/bin/bash

## This is a Slurm job script for A1 to see the difference between iom_sequential and iom_cpp.out with perf stat

#SBATCH --job-name=iom
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=1gb
#SBATCH --time=00:20:00
#SBATCH --output=iom_%j.slurmlog
#SBATCH --error=iom_%j.slurmlog
#SBATCH --mail-type=NONE

echo "Running iom job!"
echo "We are running on $(hostname)"
echo "Job started at $(date)"
echo "Arguments to your executable: $@"

# Runs your script with the arguments you passed in
echo "Running iom now..."
srun perf stat -e cycles,instructions,cache-references,cache-misses ./iom_cpp.out $@
srun perf stat -e cycles,instructions,cache-references,cache-misses ./iom_sequential test.in sequential.out 1


echo "Job ended at $(date)"