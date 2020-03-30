#!/bin/false
# Do not execute.  Only load via source.

if [ -z "${__CONFIGS_BASE__}" ]; then
  __CONFIGS_BASE__=true

  # Directories and data files.
  DATA_DIR=${HOME}/data/chembl_ic50_foodb_formatted_for_chemprop/20200326
  TRAIN_SPLIT=${DATA_DIR}/chemprop_input_train_fold_chembl.csv
  TRAIN_FEATURES=${DATA_DIR}/chemprop_input_train_fold_chembl.rdkit_2d_features.npz
  VAL_SPLIT=${DATA_DIR}/chemprop_input_validate_fold_chembl.csv
  VAL_FEATURES=${DATA_DIR}/chemprop_input_validate_fold_chembl.rdkit_2d_features.npz
  TEST_SPLIT=${DATA_DIR}/chemprop_input_test_fold_foodb.csv
  TEST_FEATURES=${DATA_DIR}/chemprop_input_test_fold_foodb.rdkit_2d_features.npz
  OUTPUT_ROOT=${HOME}/outputs/models/chemprop
  OUTPUT_BASE_DIR=${OUTPUT_ROOT}/$(date +%Y%m%d)
  PREDICTIONS_ROOT=${HOME}/outputs/predictions/chemprop
  PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/$(date +%Y%m%d)

  # Hyperparameters.
  EPOCHS=30
fi  # __CONFIGS_BASE__
