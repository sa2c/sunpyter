### Please modify this file and rename it as shellsetup.sh
# This file contains the commands to set up the jupyter notebook environment
# correctly.
# 1 activation of a conda environment;
# 2 choosing a directory where to start the jupyter notebook;

# This is an EXAMPLE conda environment containing a jupyter notebook installation
# Please use yours if your notebooks require different packages
module load anaconda/2021.05
source activate /PATH-TO-YOUR-CONDA-ENV
# Speficy working directory
cd