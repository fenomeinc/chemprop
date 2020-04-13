#!/bin/bash
#
# Like run_multi_base_models.sh, but doesn't use a holdout validate set -- just tries to
# optimize on the complete data.

source ${HOME}/work/fl65/py65/utils/sh_utils.sh

usage () {
  cat <<EOF
Usage:
  run_multi_base_models_unified_data.sh -c /path/to/config.sh
EOF
}

while getopts "hc:" opt; do
    case ${opt} in
        c)
            CONFIG_FILE=${OPTARG}
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

mkdir -p "${OUTPUT_BASE_DIR}"
LOGFILE=${OUTPUT_BASE_DIR}/runner_rig.log
savelog -t -c 10 "${LOGFILE}"
py65::assert_exists "${UNIFIED_SPLIT}"
echo "${EXPT_DESCR}" > "${OUTPUT_BASE_DIR}/experiment_description.txt"

for iter in 0 1 2 3 4 5; do
  OUTPUT_DIR=${OUTPUT_BASE_DIR}/${iter}
  mkdir -p "${OUTPUT_DIR}"
  export OUT_DIR=${OUTPUT_DIR}
  py65::log "Starting run for iter ${iter}"
  py65::execute python ./train.py \
    --epochs="${EPOCHS}" \
    --data_path="${UNIFIED_SPLIT}" \
    --dataset_type=classification \
    --save_dir="${OUTPUT_DIR}" \
    --split_sizes 0.98 0.02 0.0
done
py65::log "Done with all training.  Starting classification."

./classify_test_data_multi.sh -c "${CONFIG_FILE}" -d "${EXPT_DATE}"

py65::log  "Done with all classification.  Shutting down machine."
sudo shutdown -h now
