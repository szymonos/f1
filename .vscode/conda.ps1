#!/bin/bash
# *Parameters
$ENV_FILE = 'conda.yaml'
$ENV_NAME = (Select-String '^name:' $ENV_FILE -Raw).Split(':')[1].Trim(); $ENV_NAME

# list
conda env list
# create
conda env create --file $ENV_FILE --verbose
# update python version inside environment
conda install -n $ENV_NAME python=3.9
# install packages to existing environment
conda env update --file $ENV_FILE --prune
# list installed packages
conda list
# remove
conda env remove --name $ENV_NAME
# update conda packages
conda update --name base conda
conda update --all
# activate/deactivate environment
conda activate $ENV_NAME
conda deactivate
