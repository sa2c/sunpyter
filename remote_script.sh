#!/bin/bash 
# This step
# sets up the jupyter notebook environment correctly.
# 1 activation of a conda environment;
# 2 choosing a directory where to start the jupyter notebook;

# This is a conda environment containing a jupyter notebook installation
module load anaconda/2020.07
source activate /scratch/s.michele.mesiti/conda_example # FIXME
# Setting the working directory 
cd #FIXME 

ACCOUNT=scw1000 #FIXME
LOG=~/sunpyter_log.txt
rm -r $LOG
touch $LOG
# $LOG must be visible
# only by the user
# because it contains the auth token!
chmod go-r $LOG 
sbatch --partition development \
    -A $ACCOUNT \
    -o $LOG \
    -J SUNPYTER \
    --dependency=singleton \
    -n 1 \
    --oversubscribe \
    jupyter notebook --no-browser --ip='*'

# This is used to sends the output of the log
# to the user's machine via stdout
tail -f $LOG 

