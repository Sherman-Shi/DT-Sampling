#!/bin/bash

# List of environments
environments=("hopper-medium-v2")

# Function to generate a random seed
generate_random_seed() {
    echo $((RANDOM % 10000))  # Generates a random seed between 0 and 9999
}

# Create a logs directory if it doesn't exist
mkdir -p logs

# Define target value probability thresholds
thresholds=(0.2 0.5 0.8 0.9)

# Run experiments for each threshold
for threshold in "${thresholds[@]}"; do
    for env in "${environments[@]}"; do
        for i in {1..2}; do  # Run 2 experiments for each environment and threshold
            train_seed=$(generate_random_seed)
            eval_seed=$(generate_random_seed)
            
            echo "Running experiment with environment: $env, train seed: $train_seed, eval seed: $eval_seed, threshold: $threshold"
            
            # Determine the GPU to use (CUDA:0 or CUDA:1)
            gpu_id=$((i % 2))  # Alternate between 0 and 1

            # Start the experiment in the background and capture the PID
            python DT-Uncertainty.py --env_name "$env" \
                            --train_seed "$train_seed" \
                            --eval_seed "$eval_seed" \
                            --name "experiment_${env}_train_seed_${train_seed}_eval_seed_${eval_seed}_threshold_${threshold}" \
                            --group "DT-U-D4RL-head-threshold_target-dev" \
                            --device "cuda:$gpu_id" \
                            --project "DT_Uncertainty_Exploration" \
                            --target_value_prob_threshold "$threshold" \
                            > "logs/experiment_${env}_train_${train_seed}_eval_${eval_seed}_threshold_${threshold}_pid_$$.log" 2>&1 &

            pid=$!  # Get the PID of the last background process
            echo "Started experiment with PID: $pid"
            
            # If two experiments are running, wait for them to complete
            if (( i % 2 == 0 )); then
                wait
            fi
            
            echo "Experiment with environment: $env, train seed: $train_seed, eval seed: $eval_seed, threshold: $threshold started."
        done
    done
done

# Wait for any remaining background processes to complete
wait
