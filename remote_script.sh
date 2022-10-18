#!/bin/bash
# Please specify your SCW project account (for example, scwXXXX). 
ACCOUNT=scw1000 # This is an example of SCW account.
# Please specify the partition for running Sunpyter.
PARTITION=accel_ai # Please specify the partition you want to use.

# This lists all the available GPU partitions on Sunbird.
# accel_ai, accel_ai_dev, accel_ai_mig, gpu, s_gpu_eng
# If you don't specify a GPU partition, Sunpyter will run on CPU only. 

# This is a conda environment containing a Jupyter Notebook installation.
# Please specify your own customised conda environment if you need.
CONDA_ENV_PATH=/scratch/s.tianyi.pan/jupyter_gpu

# Please specify the working directory for your Jupyter notebooks.
WORKDIR=/home/$USER

# For CPU only.
# Please specify the number of CPU cores you need.
NUM_CPU=4 # This is the default setting (4 cores).

# For GPU only.
# Please specify the number of GPUs you need.
NUM_GPU=1 # This is the default setting (1 GPU).

# Partition selection
if ([ "$PARTITION" == "accel_ai" ] || [ "$PARTITION" == "accel_ai_dev" ] || [ "$PARTITION" == "accel_ai_mig" ] || [ "$PARTITION" == "gpu" ] || [ "$PARTITION" == "s_gpu_eng" ])
then
    GRES_DIRECTIVE="--gres=gpu:${NUM_GPU}"
else
    GRES_DIRECTIVE="--ntasks=$NUM_CPU"
fi

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

sbatch -A $ACCOUNT \
    --partition=${PARTITION} \
    -o $LOG \
    -n 1\
    ${GRES_DIRECTIVE} \
    -J SUNPYTER_$USER \
    --dependency=singleton \
    --oversubscribe \
    job_script_sunpyter.sh

# This is used to sends the output of the log
# to the user's machine for scraping 
tail -f $LOG 
