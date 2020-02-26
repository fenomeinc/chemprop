import numpy as np
import csv
import argparse
from tqdm import tqdm
from chemprop.features.features_generators import rdkit_2d_features_generator
from chemprop.features.utils import save_features

"""Utility to pre-compile SMILES to rdkit2d features.

Chemprop's train.py can construct derived chemical features on the fly, but doing
so slows down training considerably.  This utility constructs the same feature set
in batch mode and caches it to disk.  train.py can then load it from disk rather
than regenerating it.
"""


def handle_commandline() -> argparse.Namespace:
    args = argparse.ArgumentParser()
    args.add_argument('--input', type=str, required=True,
                      help='Input CSV file containing a SMILES column.')
    args.add_argument('--output', type=str, required=True,
                      help='Output .npz file into which to write the compiled features.')
    args.add_argument('--n_rows', type=int, default=None,
                      help='Number of rows in the input file.  Optional; used only for progress display.')
    return args.parse_args()


def main(args: argparse.Namespace):
    with open(args.input, 'r', newline='') as lines_in:
        records_in = csv.DictReader(lines_in)
        features = []
        for record in tqdm(records_in, total=args.n_rows):
            features.append(rdkit_2d_features_generator(record['smiles']))
        save_features(args.output, features=features)


if __name__ == '__main__':
    main(handle_commandline())
