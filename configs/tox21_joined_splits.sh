#!/bin/false
# Do not execute.  Only load via source.

# Config for running pre-split data, where the base data is Tox21 joined and cleaned with
# ChEMBL and PDBbind.

if [ -z "${__CONFIGS_TOX21_SPLIT__}" ]; then
  __CONFIGS_TOX21_SPLIT__=true

  EXPT_DESCR="Chemprop with base hyperparams run on full Tox21+ChEMBL train data."

  # Directories and data files.
  DATA_DATESTAMP=20200924
  DATA_DIR=${HOME}/data/tox21/20200604_tox21_complete_dataset/uniform_joined_and_split/20200924_reformatted_for_chemprop/pivoted
  # The following two variables need to be substituted with /usr/bin/printf before use.
  # They take two subsitutions: the data class (EC50_bin or IC50_bin) and the split
  # index (0-9 inclusive).
  TRAIN_SPLIT_PATTERN="${DATA_DIR}/%s/train_split=%d.pivoted.csv"
  VAL_SPLIT_PATTERN="${DATA_DIR}/%s/test_split=%d.pivoted.csv"
  TEST_SPLIT="${DATA_DIR}/2020-09-30_foodb_compounds_notox21_smiles_only.csv"
  OUTPUT_ROOT=${HOME}/outputs/models/chemprop_on_joined_tox21
  OUTPUT_BASE_DIR=${OUTPUT_ROOT}/${MODEL_DATE:-$(date +%Y%m%d)}
  PREDICTIONS_ROOT=${HOME}/outputs/predictions/chemprop_on_joined_tox21
  PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/${MODEL_DATE:-$(date +%Y%m%d)}

  # Hyperparameters.
  # Note: Chemprop doesn't natively support early stopping.  :-/
  EPOCHS=35
  BATCH_SIZE=50
fi  # __CONFIGS_TOX21_SPLIT__
