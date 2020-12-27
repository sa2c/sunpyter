#!/bin/bash 
ACCOUNT=scw1000 #FIXME
# This is a conda environment containing a jupyter notebook installation
CONDA_ENV_PATH=/scratch/s.michele.mesiti/conda_example #FIXME
WORKDIR=/scratch/s.michele.mesiti #FIXME

# This step
# sets up the jupyter notebook environment correctly.
# 1 activation of a conda environment;
# 2 choosing a directory where to start the jupyter notebook;
module load anaconda/2020.07
source activate $CONDA_ENV_PATH
# Setting the working directory 
cd $WORKDIR 

LOG=~/sunpyter_log.txt
rm -r $LOG
touch $LOG # to be able to monitor it

# $LOG must be visible
# only by the user
# because it contains the auth token!
chmod go-r $LOG
# launching the job asynchroniously,
# we can get the job id scraping the output
sbatch --partition development \
    -A $ACCOUNT \
    -o $LOG \
    -J SUNPYTER \
    --dependency=singleton \
    -n 1 \
    --oversubscribe \
    jupyter notebook --no-browser --ip='*'

# This is used to sends the output of the log
# to the user's machine for scraping 
tail -f $LOG 

