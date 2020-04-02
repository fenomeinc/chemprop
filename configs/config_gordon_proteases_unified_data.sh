#!/bin/false
# Do not execute.  Only load via source.

if [ -z "${__CONFIGS_GORDON_PROTEASES_UNIFIED_DATA__}" ]; then
  __CONFIGS_GORDON_PROTEASES_UNIFIED_DATA__=true
  source configs/base.sh

  read -r -d '' EXPT_DESCR <<EOF
  Chemprop model with base parameters run on unified ChEMBL, Gordon et al. proteins,
  and Coronavirus protease proteins.  Run against unified dataset of all tuples, with
  no explicit holdout of validation data.  (Though the Chemprop code does do an internal
  validation split on its own.)
EOF

fi  # __CONFIGS_GORDON_PROTEASES_UNIFIED_DATA__
