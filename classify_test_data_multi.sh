#!/bin/bash

source configs/config_gordon_proteases_unified_data.sh
source ${HOME}/work/fl65/py65/utils/sh_utils.sh

EXPT_DATE=20200402
OUTPUT_BASE_DIR=${OUTPUT_ROOT}/${EXPT_DATE}
PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/${EXPT_DATE}
LOGFILE=${OUTPUT_BASE_DIR}/runner_rig.log

mkdir -p "${PREDICTIONS_BASE_DIR}"
py65::assert_exists "${TEST_SPLIT}"

py65::log "Starting classification."
py65::log "Input data from ${TEST_SPLIT}"
py65::log "Log file at ${LOGFILE}"
py65::log "Predictions written to ${PREDICTIONS_BASE_DIR}"

echo "${EXPT_DESCR}" > "${PREDICTIONS_BASE_DIR}/experiment_description.txt"

for iter in 0 1 2 3 4 5; do
  PREDICTIONS_PATH=${PREDICTIONS_BASE_DIR}/${iter}/fold_0
  mkdir -p "${PREDICTIONS_PATH}"
  export OUT_DIR="${PREDICTIONS_PATH}"
  py65::log "Classifying iteration ${iter}"
  py65::execute python ./predict.py \
      --test_path="${TEST_SPLIT}" \
      --checkpoint_path="${OUTPUT_BASE_DIR}"/${iter}/fold_0/model_0/model.pt \
      --preds_path="${PREDICTIONS_PATH}"/foodb_test_fold_predictions.csv
done
