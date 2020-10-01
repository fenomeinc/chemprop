#!/bin/bash

source ${HOME}/work/fl65/py65/utils/sh_utils.sh
usage () {
  cat <<EOF
Usage:
  classify_test_data_multi.sh -c /path/to/config.sh -d model_run_date
EOF
}

while getopts "hc:d:" opt; do
    case ${opt} in
        c)
            CONFIG_FILE=${OPTARG}
            ;;
        d)
            MODEL_DATE=${OPTARG}
            ;;
        \?)
            usage
            exit 1
            ;;
        h)
            usage
            exit 0
            ;;
    esac
done
if [ -z "${CONFIG_FILE}" ]; then
  echo "-c config_file.sh argument is required."
  exit 1
fi
source "${CONFIG_FILE}"
if [ -z "${MODEL_DATE}" ]; then
  echo "-d YYYYMMDD experiment date argument is required."
fi

OUTPUT_BASE_DIR=${OUTPUT_ROOT}/${MODEL_DATE}
PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/${MODEL_DATE}
LOGFILE=${OUTPUT_BASE_DIR}/runner_rig.log

mkdir -p "${PREDICTIONS_BASE_DIR}"
py65::assert_exists "${TEST_SPLIT}"

py65::log "Starting classification."
py65::log "Input data from ${TEST_SPLIT}"
py65::log "Log file at ${LOGFILE}"
py65::log "Predictions written to ${PREDICTIONS_BASE_DIR}"

echo "${EXPT_DESCR}" > "${PREDICTIONS_BASE_DIR}/experiment_description.txt"

for iter in 0 1 2 3 4 5 6 7 8 9; do
  # TODO(tlane): Generalize to EC2 when we have predictions for it.
  CLASS=IC50_bin
  PREDICTIONS_PATH=${PREDICTIONS_BASE_DIR}/${CLASS}/split=${iter}
  mkdir -p "${PREDICTIONS_PATH}"
  export OUT_DIR="${PREDICTIONS_PATH}"
  py65::log "Classifying iteration ${iter}"
  py65::execute python ./predict.py \
      --test_path="${TEST_SPLIT}" \
      --checkpoint_path="${OUTPUT_BASE_DIR}"/${CLASS}/split=${iter}/fold_0/model_0/model.pt \
      --preds_path="${PREDICTIONS_PATH}"/foodb_test_fold_predictions.csv
  py65::execute python ./predict.py \
      --test_path=$(printf ${VAL_SPLIT_PATTERN} ${CLASS} ${iter}) \
      --checkpoint_path="${OUTPUT_BASE_DIR}"/${CLASS}/split=${iter}/fold_0/model_0/model.pt \
      --preds_path="${PREDICTIONS_PATH}"/tox21_test_predictions.csv
done
