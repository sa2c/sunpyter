#!/bin/bash 
ACCOUNT=scw1738
# This is a conda environment containing a jupyter notebook installation
CONDA_ENV_PATH=/scratch/s.michele.mesiti/dataaid
WORKDIR=/cdt_storage/$USER

export JUPYTER_CONFIG_DIR=$CONDA_ENV_PATH/etc/jupyter

# This directory contains also the notebook secret, 
# so it must be owned by the user.
export JUPYTER_DATA_DIR=$WORKDIR/share/jupyter
export JUPYTER_RUNTIME_DIR=$WORKDIR/.local/share/jupyter

# This step
# sets up the jupyter notebook environment correctly.
# 1 activation of a conda environment;
# 2 choosing a directory where to start the jupyter notebook;
module load anaconda/2020.07
source activate $CONDA_ENV_PATH
# Setting the working directory 

LOG=~/sunpyter_log.txt
rm -r $LOG
touch $LOG # to be able to monitor it

# $LOG must be visible
# only by the user
# because it contains the auth token!
chmod go-r $LOG
# launching the job asynchroniously,
# we can get the job id scraping the output

cat > job_script_sunpyter.sh <<SCRIPT_CONTENT
#!/bin/bash
if [ -d $WORKDIR ]
then
    jupyter notebook --notebook-dir $WORKDIR --no-browser --ip='*'
else
    echo "ERROR: $WORKDIR does not exist."
    echo "ERROR: Make sure you do the necessary steps to create it first."
fi
SCRIPT_CONTENT

sbatch --partition s_highmem_cdt \
    -A $ACCOUNT \
    -o $LOG \
    -J SUNPYTER \
    --dependency=singleton \
    -n 1 \
    --oversubscribe \
    job_script_sunpyter.sh

# This is used to sends the output of the log
# to the user's machine for scraping 
tail -f $LOG 

