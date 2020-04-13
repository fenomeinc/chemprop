#!/bin/false
# Do not execute.  Only load via source.

if [ -z "${__CONFIGS_BASE__}" ]; then
  __CONFIGS_BASE__=true

  # Directories and data files.
  DATA_DATESTAMP=20200325
  DATA_DIR=${HOME}/data/tox21/${DATA_DATESTAMP}
  TRAIN_SPLIT=${DATA_DIR}/tox21_formatted_for_chemprop.csv
  TEST_SPLIT=${DATA_DIR}/chemprop_input_test_fold_foodb.csv
  # Combination of train and validate.
  UNIFIED_SPLIT=${DATA_DIR}/tox21_formatted_for_chemprop.csv
  OUTPUT_ROOT=${HOME}/outputs/models/tox21
  OUTPUT_BASE_DIR=${OUTPUT_ROOT}/$(date +%Y%m%d)
  PREDICTIONS_ROOT=${HOME}/outputs/predictions/tox21
  PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/$(date +%Y%m%d)

  # Hyperparameters.
  EPOCHS=30
fi  # __CONFIGS_BASE__
