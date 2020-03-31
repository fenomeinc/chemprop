#!/bin/bash

source configs/base.sh
source ${HOME}/work/fl65/py65/utils/sh_utils.sh

EXPT_DATE=20200330
OUTPUT_BASE_DIR=${OUTPUT_ROOT}/${EXPT_DATE}
PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/${EXPT_DATE}
LOGFILE=${OUTPUT_BASE_DIR}/runner_rig.log

py65::log "Starting classification."
py65::log "Input data from ${TEST_SPLIT}"
py65::log "Log file at ${LOGFILE}"
py65::log "Predictions written to ${PREDICTIONS_BASE_DIR}"

for iter in 0 1 2 3 4 5; do
  PREDICTIONS_PATH=${PREDICTIONS_BASE_DIR}/${iter}/fold_0
  mkdir -p "${PREDICTIONS_PATH}"
  export OUT_DIR=${OUTPUT_DIR}
  py65::log "Classifying iteration ${iter}"
  p65::execute python ./predict.py \
      --test_path="${TEST_SPLIT}" \
      --checkpoint_path="${OUTPUT_BASE_DIR}"/${iter}/fold_0/model_0/model.pt \
      --preds_path="${PREDICTIONS_PATH}"/foodb_test_fold_predictions.csv
done
