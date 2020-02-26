#!/bin/bash
#
# Run multiple iterations of the RDKIT-featurized model.  Note that this requires
# that the feature sets have been pre-generated via generate_rdkit_features.py.

source configs/base.sh

for iter in a b c d e f; do
  OUTPUT_DIR=${OUTPUT_BASE_DIR}_${iter}
  mkdir -p ${OUTPUT_DIR}
  python ./train.py \
      --data_path=${TRAIN_SPLIT} \
      --features_path=${TRAIN_FEATURES} \
      --dataset_type=classification \
      --save_dir=${OUTPUT_DIR} \
      --separate_val_path=${VAL_SPLIT} \
      --separate_val_features_path=${VAL_FEATURES} \
      --no_features_scaling
done

sudo shutdown -h now
