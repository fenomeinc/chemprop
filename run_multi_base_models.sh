#!/bin/bash

source configs/base.sh

for iter in a b c; do
  OUTPUT_DIR=${OUTPUT_BASE_DIR}_${iter}
  mkdir -p ${OUTPUT_DIR}
  python ./train.py \
    --data_path=${TRAIN_SPLIT} \
    --dataset_type=classification \
    --save_dir=${OUTPUT_DIR} \
    --separate_val_path=${VAL_SPLIT}
done

sudo shutdown -h now
