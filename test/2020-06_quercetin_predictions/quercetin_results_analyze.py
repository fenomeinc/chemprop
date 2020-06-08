import numpy as np  
import pandas as pd

df_quer = pd.concat([pd.read_csv('chemprop_quercetin_predictions_{}.csv'.format(r))\
    .set_index(['smiles','uniprot_id']).rename({'prediction':'chemprop{}'.format(r)}, axis=1)
           for r in range(6)], axis=1)

## Drop SMILES since we're only looking at 1 compound
df_quer.index = df_quer.index.get_level_values(1)
## Write out
df_quer_agg = df_quer.agg([np.mean, np.std], axis=1)
df_quer_agg.to_csv('chemprop_quercetin_predictions_agg.csv')
