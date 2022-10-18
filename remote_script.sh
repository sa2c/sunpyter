#!/bin/bash
# Please speficy your SCW project account (for example, scwXXXX). 
ACCOUNT=scw1000 # This is an example of SCW account.

# Please speficy the partition for running your Jupyter notebooks.
# If you need CPU then use "compute". If you need GPU, please speficy "accel_ai".
PARTITION=accel_ai # Must be either "compute" or "accel_ai"

# For "compute" ONLY! 
# Please speficy the number of CPU cores you need.
NUM_CPU=4 # This is the default setting (4 cores).

# For "accel_ai" ONLY! 
# Please speficy the number of GPUs you need.
NUM_GPU=1 # This is the default setting (1 GPU).

# This is a very simple conda environment containing a jupyter notebook installation
# Please speficy your own customised conda environment if you need.
CONDA_ENV_PATH=/scratch/s.tianyi.pan/jupyter_gpu

# Please specify the working directory for your Jupyter notebooks.
WORKDIR=/home/$USER

export JUPYTER_CONFIG_DIR=$CONDA_ENV_PATH/etc/jupyter

# This directory contains also the notebook secret, 
# so it must be owned by the user.
export JUPYTER_DATA_DIR=$HOME/.local/share/jupyter
export JUPYTER_RUNTIME_DIR=$WORKDIR/.local/share/jupyter

# This step
# sets up the jupyter notebook environment correctly.
# 1 activation of a conda environment;
# 2 choosing a directory where to start the jupyter notebook;
module load anaconda/2021.05
source activate $CONDA_ENV_PATH

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

if [ "$PARTITION" == "compute" ]
then
    sbatch -A $ACCOUNT \
        --partition=compute \
        -o $LOG \
        -J SUNPYTER_$USER \
        --dependency=singleton \
        -n 1 \
        --ntasks=&NUM_CPU \
        --oversubscribe \
        job_script_sunpyter.sh
    
elif [ "$PARTITION" == "accel_ai" ]
then
    sbatch -A $ACCOUNT \
        --partition=accel_ai \
        -o $LOG \
        -J SUNPYTER_$USER \
        --dependency=singleton \
        -n 1 \
        --gres=gpu:$NUM_GPU \
        --oversubscribe \
        job_script_sunpyter.sh

else
    echo 'Wrong launch specification, use either "compute" or "accel_ai".'
    exit
fi
# This is used to sends the output of the log
# to the user's machine for scraping 
tail -f $LOG 