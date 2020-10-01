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

# Target output template is
#   s3://py65/predictions/2020-09_cpi_prediction_sets/[DATA SUBSET]/[MY MODEL]/[MODEL RUN NAME]/split_i/[AGONIST/ANTAGONIST]/[TEST SET / FOODB].csv
# full/chemprop/20200929/split_9/antagonist/test_set.csv
for iter in 0 1 2 3 4 5 6 7 8 9; do
  # TODO(tlane): Generalize to EC2 when we have predictions for it.
  CLASS=IC50_bin
  CLASS_NAME=antagonist
  PREDICTIONS_PATH=${PREDICTIONS_BASE_DIR}/split_${iter}/${CLASS_NAME}
  mkdir -p "${PREDICTIONS_PATH}"
  export OUT_DIR="${PREDICTIONS_PATH}"
  py65::log "Classifying iteration ${iter}"
  py65::execute python ./predict.py \
      --test_path="${TEST_SPLIT}" \
      --checkpoint_path="${OUTPUT_BASE_DIR}"/${CLASS}/split=${iter}/fold_0/model_0/model.pt \
      --preds_path="${PREDICTIONS_PATH}"/foodb.csv
  py65::execute python ./predict.py \
      --test_path=$(printf ${VAL_SPLIT_PATTERN} ${CLASS} ${iter}) \
      --checkpoint_path="${OUTPUT_BASE_DIR}"/${CLASS}/split=${iter}/fold_0/model_0/model.pt \
      --preds_path="${PREDICTIONS_PATH}"/test_set.csv
done
