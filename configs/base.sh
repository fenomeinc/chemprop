#!/bin/false
# Do not execute.  Only load via source.

if [ -z "${__CONFIGS_BASE__}" ]; then
  __CONFIGS_BASE__=true

  DATA_DIR=${HOME}/data/chembl_ic50_foodb_formatted_for_chemprop/20200203
  TRAIN_SPLIT=${DATA_DIR}/chemprop_input_train_fold_chembl.csv
  TRAIN_FEATURES=${DATA_DIR}/chemprop_input_train_fold_chembl.rdkit_2d_features.npz
  VAL_SPLIT=${DATA_DIR}/chemprop_input_validate_fold_chembl.csv
  VAL_FEATURES=${DATA_DIR}/chemprop_input_validate_fold_chembl.rdkit_2d_features.npz
  TEST_SPLIT=${DATA_DIR}/intermediate_tables/foodb_test_fold_smiles_only.csv
  OUTPUT_ROOT=${HOME}/outputs/models/chemprop
  OUTPUT_BASE_DIR=${OUTPUT_ROOT}/$(date +%Y%m%d)

fi  # __CONFIGS_BASE__
