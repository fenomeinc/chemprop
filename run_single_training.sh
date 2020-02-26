#!/bin/bash
#
# Run a single iteration of model training using the recommended RDKIT-generated
# molecular features.

DATA_DIR=/home/tlane/data/chembl_ic50_foodb_formatted_for_chemprop/20200203
TRAIN_SPLIT=${DATA_DIR}/chemprop_input_train_fold_chembl.csv
VAL_SPLIT=${DATA_DIR}/chemprop_input_validate_fold_chembl.csv
OUTPUT_ROOT=/home/tlane/outputs/models/chemprop
OUTPUT_DIR=${OUTPUT_ROOT}/$(date +%Y%m%d)
mkdir -p ${OUTPUT_DIR}

python ./train.py \
  --data_path=${TRAIN_SPLIT} \
  --dataset_type=classification \
  --save_dir=${OUTPUT_DIR} \
  --separate_val_path=${VAL_SPLIT} \
  --features_generator=rdkit_2d_normalized \
  --no_features_scaling
