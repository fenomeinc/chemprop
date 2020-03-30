#!/bin/bash

source configs/base.sh
source ${HOME}/work/fl65/py65/utils/sh_utils.sh
LOGFILE=${OUTPUT_BASE_DIR}/runner_rig.log

for iter in 0 1 2 3 4 5; do
  OUTPUT_DIR=${OUTPUT_BASE_DIR}/${iter}
  mkdir -p ${OUTPUT_DIR}
  export OUT_DIR=${OUTPUT_DIR}
  py65::log "Starting run for iter ${iter}"
  py65::execute python ./train.py \
    --epochs=${EPOCHS} \
    --data_path=${TRAIN_SPLIT} \
    --dataset_type=classification \
    --save_dir=${OUTPUT_DIR} \
    --separate_val_path=${VAL_SPLIT}
done
py65::log "Done with all training.  Starting classification."

./classify_test_data_multi.sh

py65::log  "Done with all classification.  Shutting down machine."
sudo shutdown -h now
