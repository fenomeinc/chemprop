#!/usr/bin/env python3
import click, os, subprocess, logging
import pandas as pd
from tempfile import NamedTemporaryFile

name='batch_mode_prediction'

def run_chemprop(in_df, python_command, chemprop_model_path, chemprop_predict_path):
    """Run Chemprop on the data in *in_df*
    """
    ## Write input
    logging.info('Loading input chunk ', input_file, 'chunk', k)
    temp_in_file = NamedTemporaryFile()
    temp_out_file = NamedTemporaryFile()
    in_df_m.to_csv(temp_in_file.name, index=False)
    
    ## Run Chemprop
    logging.info('Running Chemprop on ', input_file.name, 'chunk', k)
    p = subprocess.Popen(f"{python_command} {chemprop_predict_path} \
        --test_path='{temp_in_file.name}' \
        --checkpoint_path='{chemprop_model_path.name}' \
        --preds_path='{temp_out_file.name}'", shell=True, stdout=subprocess.PIPE)
    for line in p.stdout: print(line)
    p.wait()
    print(p.returncode)
    
    return temp_in_file, temp_out_file

def load_chemprop_outputs(temp_out_file, no_filter_proteins=True, 
                          in_df=None, protein_list=None):
    """Load the outputs of running Chemprop and filter them down to the provided protein_list or
    the proteins of in_df, unless no_filter_proteins is set to True.
    """
    assert protein_list is None or no_filter_proteins is False
    ## Open the Chemprop output file and melt it
    logging.info('Opening Chemprop outputs ', temp_out_file.name)
    out_df = pd.read_csv(temp_out_file.name).melt(
                id_vars = ['smiles'], var_name='uniprot_id', 
                value_name = 'prediction')
    
    ## Filter the output
    if no_filter_proteins:
        out_df_sel = out_df
        protein_list_df = None
    else:
        logging.info('Filtering Chemprop outputs ', temp_out_file.name)
        if protein_list is None:
            dense_in_df = in_df.melt(                    
                        id_vars = ['smiles'], var_name='uniprot_id', 
                        value_name = 'training_label').dropna()
            out_df_sel = out_df.merge(dense_in_df, on=['smiles', 'uniprot_id'], how='right')
            protein_list_df = None
        else:
            protein_list_df = pd.read_csv(protein_list, header=None).iloc[:,0]
            out_df_sel = out_df[out_df['uniprot_id'].isin(protein_list_df)]
    
    return out_df_sel, protein_list_df

def check_protein_filtering(in_df, out_df_sel, protein_list=None, protein_list_df=None):
    """Runs a set of assertions to validate that the input and output predictions
    match the expectations given the protein filtering parametrs.
    """
    N_out = len(in_df, out_df_sel)
    N_in = (in_df.iloc[:,1:].isnull()==False).sum().sum()
    if protein_list is None:
        assert N_in == N_out
    else:
        ## Assert that every input compound is in the output
        assert in_df['smiles'].isin(out_df['smiles']).mean() == 1.0
        ## Count how many input proteins are in the output.  Note this may be
        ## <100% if the model was not trained for every protein.
        N_prot_predicted = protein_list_df.isin(out_df['uniprot_id']).sum()
        if k==0 and N_prot_predicted < len(protein_list_df):
            logging.warning(f'Able to make predictions for only {N_prot_predicted} of {len(protein_list_df)} input proteins')
        ## Assert that we have the correct number of compound+protein prediction pairs
        N_total = N_prot_predicted * len(in_df)
        assert N_out == N_total

def chemprop_end_to_end(in_df, python_command, chemprop_model_path, chemprop_predict_path,
                        no_filter_proteins, protein_list):
    """Run Chemprop end to end on a DataFrame in_df, including filtering out duplicate
    compounds, writing to a tempoary file, running Chemprop, reading outputs from a temporary
    file, and filtering to relevant proteins (if desired).
    """
    ## Filter out duplicate training examples.  
    ## Doing a max aggregation means we replace null values with
    ## measurements from a duplicate row if available. 
    ## NOTE: this only de-duplicates within chunks.  It is still
    ## possible that there are duplicate compounds across chunks.
    in_df_m = in_df.groupby('smiles').max().reset_index()
    
    ## Run Chemprop
    temp_in_file, temp_out_file = run_chemprop(in_df_m, 
                python_command, chemprop_model_path, chemprop_predict_path)
    
    ## Load the Chemprop outputs
    out_df_sel, protein_list_df = load_chemprop_outputs(
        temp_out_file, no_filter_proteins=no_filter_proteins, 
        in_df=in_df_m, protein_list=protein_list)
    
    ## Check results to ensure protein filtering worked
    if no_filter_proteins is False:
        check_protein_filtering(in_df_m, out_df_sel, 
            protein_list=protein_list, protein_list_df=protein_list_df)
    
    temp_out_file.close()
    
    return out_df_sel


@click.command()
@click.option(
    '--chemprop_model_path',
    type=click.File('r'),
    required=True,
    help='Location of Chemprop model checkpoint to use for prediction.',
)
@click.option(
    '--input_file',
    required=True,
    type=click.File('r'),
    help='File with sparse data to be split.'
         'If not provided, a prompt will allow you to type the input text.',
)
@click.option(
    '--output_file',
    type=click.File('w'),
    help='File output for dense, one-row-per-prediction output.'
         'If not provided, the output text will just be printed.',
)
@click.option(
    '--rows_per_chunk',
    '-K',
    default=10000,
    help='The number of rows to include in each chunk.'
)
@click.option(
    '--python_command',
    default='python',
    help='Command for python installation to use.'
)
@click.option(
    '--chemprop_predict_path',
    required=True,
    help='Path for Chemprop predict script.'
)
@click.option(
    '--no_filter_proteins',
    is_flag=True,
    help='By default, we filter the output from Chemprop to select only the proteins included in the input_file.  This flag turns off that filtering.'
)
@click.option(
    '--protein_list',
    default=None,
    help='By default, we filter the output from Chemprop to select only the proteins included in the input_file.  This switch allows you to provide a separate protein list as a plaintext file (one protein uniprot_id per line, no header).'
)
def main(chemprop_model_path, input_file, output_file, 
         rows_per_chunk, python_command, chemprop_predict_path, 
         no_filter_proteins, protein_list):
    """This script takes a sparse input matrix for chemprop of e.g. training 
    data, chunks it and generate Chemprop predictions, then reads them back in, 
    melts them, and filters them down to predictions for the dense subset of the 
    input matrix and/or a specified protein_list.  The output file has one row 
    per protein and compound with a prediction.
    """
    assert protein_list is None or no_filter_proteins is False
    
    ## Iterate over chunks
    logging.info('Loading input file ', input_file.name)
    for k, in_df in enumerate(pd.read_csv(input_file, chunksize=rows_per_chunk)):
        ## Run Chemprop
        out_df_sel = chemprop_end_to_end(in_df, python_command=python_command, 
            chemprop_model_path=chemprop_model_path, chemprop_predict_path=chemprop_predict_path,
            no_filter_proteins=no_filter_proteins, protein_list=protein_list)
    
        ## Write to the consolidated output file
        logging.info('Writing Chemprop outputs ', output_file)
        out_df_sel.to_csv(output_file, mode='a', index=False,
                          header=False if k>0 else True)
        
        ## Close temp files
        temp_out_file.close()


if __name__ == '__main__':
    main()
