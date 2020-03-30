#!/bin/bash
#
# Run a single iteration of model training using the recommended RDKIT-generated
# molecular features.

source configs/config_cmap_jli_base.sh

EXPT_DATE=20200311

OUTPUT_DIR=${OUTPUT_BASE_DIR}
mkdir -p ${OUTPUT_DIR}

python ./train.py \
  --data_path=${TRAIN_SPLIT} \
  --dataset_type=regression \
  --save_dir=${OUTPUT_DIR} \
  --separate_val_path=${VAL_SPLIT} \
  --split_type=scaffold_balanced \
  --num_folds=5 \
  --batch_size=200

sudo shutdown -h now
