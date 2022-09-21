#!/bin/bash 
# This file contains the commands to set up the jupyter notebook environment
# correctly.
# 1 activation of a conda environment;
# 2 choosing a directory where to start the jupyter notebook;
# This is a conda environment containing a jupyter notebook installation
module load anaconda/2021.05
source activate /scratch/s.tianyi.pan/jupyter_gpu
# working directory
cd
