#!/bin/bash

# List of environments
# environments=("hopper-medium-v2" "halfcheetah-expert-v2")
environments=("halfcheetah-expert-v2")

# List of reward head values to test
reward_heads=(32 64 128)

# Function to generate a random seed
generate_random_seed() {
    echo $((RANDOM % 10000))  # Generates a random seed between 0 and 9999
}

# Create a logs directory if it doesn't exist
mkdir -p logs

# Run experiments
for env in "${environments[@]}"; do
    for num_heads in "${reward_heads[@]}"; do
        for i in {1..2}; do  # Run 2 experiments for each environment and reward head setting
            train_seed=$(generate_random_seed)
            eval_seed=$(generate_random_seed)

            echo "Running experiment with environment: $env, num_reward_heads: $num_heads, train seed: $train_seed, eval seed: $eval_seed"

            # Determine the GPU to use (CUDA:0 or CUDA:1)
            gpu_id=1  # Alternate between 0 and 1

            # Start the experiment in the background and capture the PID
            python DT-Uncertainty.py --env_name "$env" \
                            --train_seed "$train_seed" \
                            --eval_seed "$eval_seed" \
                            --num_reward_heads "$num_heads" \
                            --name "experiment_${env}_heads_${num_heads}_train_seed_${train_seed}_eval_seed_${eval_seed}" \
                            --group "DT-U-D4RL-head-num-ablation-logits_epi-dev" \
                            --device "cuda:$gpu_id" \
                            --project "DT_Uncertainty_Exploration" \
                            > "logs/experiment_${env}_heads_${num_heads}_train_${train_seed}_eval_${eval_seed}_pid_$$.log" 2>&1 &

            pid=$!  # Get the PID of the last background process
            echo "Started experiment with PID: $pid"

            # If two experiments are running, wait for them to complete
            if (( i % 2 == 0 )); then
                wait
            fi

            echo "Experiment with environment: $env, num_reward_heads: $num_heads, train seed: $train_seed, eval seed: $eval_seed started."
        done
    done
done

# Wait for any remaining background processes to complete
wait
