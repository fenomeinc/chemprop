#!/bin/bash

source configs/tox21_joined_splits.sh
source ${HOME}/work/fl65/py65/utils/sh_utils.sh
LOGFILE=${OUTPUT_BASE_DIR}/runner_rig.log

for class in EC50_bin IC50_bin; do
  for split in 0 1 2 3 4; do
    OUTPUT_DIR="${OUTPUT_BASE_DIR}/${class}/split=${split}"
    mkdir -p ${OUTPUT_DIR}
    export OUT_DIR=${OUTPUT_DIR}
    py65::log "Starting run for iter ${split}"
    train_split=$(printf "${TRAIN_SPLIT_PATTERN}" ${class} ${split})
    val_split=$(printf "${VAL_SPLIT_PATTERN}" ${class} ${split})
    py65::execute python ./train.py \
      --epochs=${EPOCHS} \
      --data_path=${train_split} \
      --dataset_type=classification \
      --save_dir=${OUTPUT_DIR} \
      --separate_val_path=${val_split} \
      --batch_size=${BATCH_SIZE} \
      --split_sizes 1.0 0.0 0.0
  done
done
py65::log "Done with all training."

py65::log  "Done with all classification.  Shutting down machine."
#sudo shutdown -h now
