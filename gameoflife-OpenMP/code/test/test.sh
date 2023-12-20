#!/bin/bash

# Create the log file
touch test.log

# Redirect stdout and stderr to the log file
exec > >(tee -a test.log)
exec 2>&1

# Initialize the counter for successful tests
case_counter=0
success_counter=0

# Generate test inputs and perform tests
for i in {10..250..50}; do
    # Generate test input
    python3 gen.py --n_generations $i --n_rows $i --m_cols $i --output_file test$i.in

    # Get correct answer
    ./iom_sequential test$i.in correct$i.out 1

    # Test the program
    ../iom_cpp.out test$i.in test$i.out 20

    # Compare the output and the correct answer
    if cmp -s "test$i.out" "correct$i.out"; then
        echo -e "\033[0;32mTest $i: Passed\033[0m"
        ((success_counter++))
    else
        echo -e "\033[0;31mTest $i: Failed\033[0m"
        echo "iom_cpp.out output:"
        cat test$i.out
        echo "iom_sequential output:"
        cat correct$i.out
    fi
    ((case_counter++))
done

# Print the final result
echo "Number of test cases passed: $success_counter out of $case_counter"
