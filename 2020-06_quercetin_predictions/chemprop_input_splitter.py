#!/usr/bin/env python3
import click
import pandas as pd
import os
import subprocess
import pdb
import logging

@click.command()
@click.option(
    '--chemprop_model_path',
    type=click.File('r'),
    help='Location of Chemprop model checkpoint to use for prediction.',
)
@click.option(
    '--input_file',
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
    '--temp_file_prefix',
    default='tmp_chemprop_chunk_',
    help='The prefixes for the temporary chunk files; inputs and outputs'
    'to the chemprop model.'
)
@click.option(
    '--python_command',
    default='python',
    help='Command for python installation to use.'
)
@click.option(
    '--chemprop_predict_path',
    default='~/NES/chemprop/predict.py',
    help='Path for Chemprop predict script.'
)
@click.option(
    '--no_filter_proteins',
    is_flag=True,
    help='By default, we filter the output from Chemprop to select only the proteins included in the input_file.  This flag turns off that filtering.'
)
@click.option(
    '--protein_list',
    help='By default, we filter the output from Chemprop to select only the proteins included in the input_file.  This switch allows you to provide a separate protein list as a plaintext file (one protein uniprot_id per line, no header).'
)
def main(chemprop_model_path, input_file, output_file, 
         rows_per_chunk, temp_file_prefix, python_command, 
         chemprop_predict_path, no_filter_proteins, protein_list):
    """This script takes a sparse input matrix for chemprop of e.g. training 
    data, chunks it and generate Chemprop predictions, then reads them back in, 
    melts them, and filters them down to predictions for the dense subset of the 
    input matrix.  The output file has one row per protein and compound with 
    a prediction.
    """
    tmp_input_files = []
    tmp_output_files = []
    
    assert protein_list is None or no_filter_proteins is False
    
    ## Iterate over chunks
    logging.info("Loading input file ", input_file.name)
    for k, in_df in enumerate(pd.read_csv(input_file, chunksize=rows_per_chunk)):
        
        ## Filter out duplicate training examples.  
        ## Doing a max aggregation means we replace null values with
        ## measurements from a duplicate row if available. 
        in_df_m = in_df.groupby('smiles').max().reset_index()
        
        logging.info("Loading input chunk ", input_file, 'chunk', k)
        temp_in_file = temp_file_prefix + f'input_{k}.csv'
        tmp_input_files += [temp_in_file]
        with open(temp_in_file, 'w') as f:
            in_df_m.to_csv(f, index=False)
        
        ## Run Chemprop
        logging.info("Running Chemprop on ", input_file.name, 'chunk', k)
        temp_out_file = temp_file_prefix + f'output_{k}.csv'
        tmp_output_files += [temp_out_file]
        p = subprocess.Popen(f'{python_command} {chemprop_predict_path} \
            --test_path="{temp_in_file}" \
            --checkpoint_path="{chemprop_model_path.name}" \
            --preds_path="{temp_out_file}"', shell=True, stdout=subprocess.PIPE)
        for line in p.stdout: print(line)
        p.wait()
        print(p.returncode)
        
        ## Open the Chemprop output file and melt it
        logging.info("Opening Chemprop outputs ", temp_out_file)
        out_df = pd.read_csv(temp_out_file).melt(
                    id_vars = ['smiles'], var_name='uniprot_id', 
                    value_name = 'prediction')
        
        ## Filter the output
        if no_filter_proteins:
            out_df_sel = out_df
        else:
            logging.info("Filtering Chemprop outputs ", temp_out_file)
            if protein_list is None:
                dense_in_df = in_df_m.melt(                    
                            id_vars = ['smiles'], var_name='uniprot_id', 
                            value_name = 'training_label').dropna()
                out_df_sel = out_df.merge(dense_in_df, on=['smiles', 'uniprot_id'], how='right')
            else:
                protein_list_df = pd.read_csv(protein_list, header=None).iloc[:,0]
                out_df_sel = out_df[out_df['uniprot_id'].isin(protein_list_df)]

        
        if no_filter_proteins is False:
            N_out = len(out_df_sel)
            N_in = (in_df_m.iloc[:,1:].isnull()==False).sum().sum()
            if protein_list is None:
                assert N_in == N_out
            else:
                ## Assert that every input compound is in the output
                assert in_df_m['smiles'].isin(out_df['smiles']).mean() == 1.0
                ## Count how many input proteins are in the output.  Note this may be
                ## <100% if the model was not trained for every protein.
                N_prot_predicted = protein_list_df.isin(out_df['uniprot_id']).sum()
                if k==0 and N_prot_predicted < len(protein_list_df):
                    logging.warning(f"Able to make predictions for only {N_prot_predicted} of {len(protein_list_df)} input proteins")
                ## Assert that we have the correct number of compound+protein prediction pairs
                N_total = N_prot_predicted * len(in_df_m)
                try: assert N_out == N_total
                except: pdb.set_trace()
        
        ## Write to the consolidated output file
        logging.info("Writing Chemprop outputs ", temp_out_file)
        out_df_sel.to_csv(output_file, mode='a', index=False,
                          header=False if k>0 else True)
    
    ## Delete temporary files
    for temp_in_file in tmp_input_files: os.remove(temp_in_file)
    for temp_out_file in tmp_output_files: os.remove(temp_out_file)
        

if __name__ == '__main__':
    main()
