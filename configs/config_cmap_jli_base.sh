#!/bin/false
# Do not execute.  Only load via source.

if [ -z "${__CONFIGS_BASE__}" ]; then
  __CONFIGS_BASE__=true

  DATA_DIR=${HOME}/data/jason_li_cmap/20200311
  TRAIN_SPLIT=${DATA_DIR}/l4_lm_cancer.csv
  VALIDATION_SPLIT=${DATA_DIR}/l4_lm_primary.csv
  OUTPUT_ROOT=${HOME}/outputs/models/cmap_jli_chemprop
  OUTPUT_BASE_DIR=${OUTPUT_ROOT}/$(date +%Y%m%d)
  PREDICTIONS_ROOT=${HOME}/outputs/predictions/chemprop_jli_chemprop/
  PREDICTIONS_BASE_DIR=${PREDICTIONS_ROOT}/$(date +%Y%m%d)

fi  # __CONFIGS_BASE__
