
# aws s3 cp --profile fl65 s3://py65/models/chemprop/20200402/ ~/NES/chemprop/fl65/models/ --recursive
OUTPUT_BASE_DIR=~/NES/chemprop/fl65/models
TEST_SPLIT=quercetin_smiles.txt
PREDICTIONS_PATH=./
PROTEIN_LIST=NFKB_pathway_proteins.txt

conda activate chemprop

## Run on foodb
for iter in 0 1 2 3 4 5;
do
rm "${PREDICTIONS_PATH}"/chemprop_foodb_training_predictions_${iter}.csv
# python ~/NES/chemprop/predict.py \
#       --test_path="${TEST_SPLIT}" \
#       --checkpoint_path="${OUTPUT_BASE_DIR}"/${iter}/fold_0/model_0/model.pt \
#       --preds_path="${PREDICTIONS_PATH}"/chemprop_foodb_training_predictions_${iter}.csv
python ~/NES/covid-data-and-model-diagnostics/chemprop_input_splitter.py \
        --chemprop_model_path="${OUTPUT_BASE_DIR}"/${iter}/fold_0/model_0/model.pt \
        --input_file "${TEST_SPLIT}" \
        --output_file="${PREDICTIONS_PATH}"/chemprop_quercetin_predictions_${iter}.csv \
        --temp_file_prefix="tmp_chemprop_run${iter}_chunk_"  \
        --protein_list="${PROTEIN_LIST}" # Not backgrounded to avoid too many simultaneous processes&
done
