#!/bin/bash 
module load anaconda/2019.3
source activate
# This is a conda environment containing a jupyter notebook installation
conda activate /scratch/s.michele.mesiti/conda_example

jupyter notebook --no-browser --ip='*'

