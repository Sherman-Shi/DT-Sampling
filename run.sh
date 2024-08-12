#!/bin/bash

# Set the train seeds and eval seeds you want to use
train_seeds=(42 123 456 789 1011)
eval_seeds=(101 202 303 404 505)

# Loop through each pair of seeds and run the script
for i in "${!train_seeds[@]}"
do
  train_seed=${train_seeds[$i]}
  eval_seed=${eval_seeds[$i]}
  echo "Running with train_seed $train_seed and eval_seed $eval_seed..."
  python DT-sampling.py --train_seed $train_seed --eval_seed $eval_seed
done
