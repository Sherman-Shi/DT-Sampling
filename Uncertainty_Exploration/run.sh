#!/bin/bash

# List of environments
#environments=("hopper-medium-v2" "halfcheetah-expert-v2" "hopper-expert-v2" "halfcheetah-medium-v2")
environments=("hopper-medium-v2" "halfcheetah-expert-v2")

# Function to generate a random seed
generate_random_seed() {
    echo $((RANDOM % 10000))  # Generates a random seed between 0 and 9999
}

# Create a logs directory if it doesn't exist
mkdir -p logs

# Run experiments
for env in "${environments[@]}"; do
    for i in {1..2}; do  # Run 2 experiments for each environment
        train_seed=$(generate_random_seed)
        eval_seed=$(generate_random_seed)
        
        echo "Running experiment with environment: $env, train seed: $train_seed, eval seed: $eval_seed"
        
        # Determine the GPU to use (CUDA:0 or CUDA:1)
        gpu_id=$((i % 2))  # Alternate between 0 and 1

        # Start the experiment in the background and capture the PID
        python DT-Uncertainty.py --env_name "$env" \
                        --train_seed "$train_seed" \
                        --eval_seed "$eval_seed" \
                        --name "experiment_${env}_train_seed_${train_seed}_eval_seed_${eval_seed}" \
                        --group "${env}-experiments" \
                        --device "cuda:$gpu_id" \
                        --project "DT_Uncertainty_Exploration" \
                        > "logs/experiment_${env}_train_${train_seed}_eval_${eval_seed}_pid_$$.log" 2>&1 &

        pid=$!  # Get the PID of the last background process
        echo "Started experiment with PID: $pid"
        
        # If two experiments are running, wait for them to complete
        if (( i % 2 == 0 )); then
            wait
        fi
        
        echo "Experiment with environment: $env, train seed: $train_seed, eval seed: $eval_seed started."
    done
done

# Wait for any remaining background processes to complete
wait
