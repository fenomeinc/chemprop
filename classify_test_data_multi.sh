#!/bin/bash

source configs/base.sh

EXPT_DATE=20200226
OUTPUT_BASE_DIR=${OUTPUT_ROOT}/${EXPT_DATE}
PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/${EXPT_DATE}

for iter in a b c d e f; do
  PREDICTIONS_PATH=${PREDICTIONS_BASE_DIR}_${iter}/fold_0
  mkdir -p ${PREDICTIONS_PATH}
  python ./predict.py \
      --test_path=${TEST_SPLIT} \
      --features_path=${TEST_FEATURES} \
      --checkpoint_path=${OUTPUT_BASE_DIR}_${iter}/fold_0/model_0/model.pt \
      --preds_path=${PREDICTIONS_PATH}/foodb_test_fold_predictions.csv
done
