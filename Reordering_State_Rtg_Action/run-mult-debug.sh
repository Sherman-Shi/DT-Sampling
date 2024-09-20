#!/bin/bash

# Set the environments to run
environments=("halfcheetah-medium-v2" "halfcheetah-expert-v2" "hopper-medium-v2" "hopper-expert-v2")

# Function to run an experiment with a given script, environment, and seeds
run_experiment() {
    script=$1
    env=$2
    train_seed=$3
    eval_seed=$4
    log_dir="logs/${script}_${env}_${train_seed}_${eval_seed}"
    mkdir -p $log_dir
    echo "Running $script with env $env, train_seed $train_seed, eval_seed $eval_seed..."
    python $script --env_name $env --train_seed $train_seed --eval_seed $eval_seed > $log_dir/output.log 2>&1
}

# Loop through each environment and run the scripts in parallel
for env in "${environments[@]}"
do
    # Generate two random seeds
    train_seed_dt=$((RANDOM))
    eval_seed_dt=$((RANDOM))
    train_seed_dt_sar=$((RANDOM))
    eval_seed_dt_sar=$((RANDOM))

    # Run DT.py in parallel for the current environment
    run_experiment "DT-SRA.py" $env $train_seed_dt $eval_seed_dt &
    
    # Wait for 100 seconds before starting DT-SAR.py
    sleep 100
    
    # Run DT-SAR.py in parallel for the current environment
    run_experiment "DT-SAR-ActionSampling.py" $env $train_seed_dt_sar $eval_seed_dt_sar &

    # Wait for both parallel processes to finish before moving on to the next environment
    wait
done
