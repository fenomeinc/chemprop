#!/bin/bash

source configs/base.sh

OUTPUT_BASE_DIR=${OUTPUT_ROOT}/20200223

for iter in a b c d e f; do

  OUTPUT_PATH=${OUTPUT_BASE_DIR}_${iter}/fold_0
  mkdir -p ${OUTPUT_PATH}
  python ./predict.py \
      --test_path=${TEST_SPLIT} \
      --checkpoint_path=${OUTPUT_BASE_DIR}_${iter}/fold_0/model_0/model.pt \
      --preds_path=${OUTPUT_PATH}/foodb_test_fold_predictions.csv
done
