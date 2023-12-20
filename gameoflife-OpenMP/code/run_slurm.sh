## Sample script to run your iom program on Slurm
## Assumes that you are running within a subfolder on /nfs 
## You can run it with: ./run_slurm.sh <input_file> <output_file> <number_of_threads>
##  and it will run your executable with those three arguments.
##  The script will also automatically run the input file for iom_sequential with 1 thread

# Check that the three arguments were passed
if [ ! "$#" -eq 3 ]
then
  echo "Expecting 3 arguments (<input_file> <output_file> <number_of_threads>), got $#"
  exit 1
fi

echo "Building your program..."
make build

echo "Executing your program on Slurm..."
sbatch slurm_job.sh $@

echo -e "Job submitted!\n"
echo "Please wait for your job to finish (either check squeue, or enable --mail-type=ALL in the job script and wait for the email"
echo "Then, you can check the .out file for the final output, and check the .slurmlog file for debug information"