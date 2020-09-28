import pandas as pd
from pathlib import Path
import logging
from argparse import ArgumentParser
#from py65.utils.py65_init import py65_init

# A super quick and dirty script to reformat all the files in a directory into the
# form we need to pivot them.

def main(data_dir: Path, out_dir: Path):
    files = list(data_dir.glob('**/*_split=*.csv'))
    logging.info('Target files = %s', files)
    for f in files:
        logging.info('Processing file %s', f)
        target_col = f.parent.name
        target_dir = out_dir / target_col
        target_dir.mkdir(exist_ok=True, parents=True)
        df = pd.read_csv(f, header=0, usecols=['canonical_smiles', 'uniprot_id', target_col])
        df.drop_duplicates(subset=['canonical_smiles', 'uniprot_id'], keep='first', inplace=True)
        df.sort_values(by=['canonical_smiles', 'uniprot_id'], inplace=True)
        df[target_col] = df[target_col].astype('Int64')
        new_filename = f.stem + '.sorted_noheader' + f.suffix
        df.to_csv(target_dir / new_filename, header=False, index=False)


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    parser = ArgumentParser()
    parser.add_argument('--files_root', required=True, type=Path,
                        help='Root directory for files to process.')
    parser.add_argument('--out_dir', required=True, type=Path,
                        help='Destination directory.')
    # args = py65_init(parser)
    args = parser.parse_args()
    main(args.files_root, args.out_dir)
