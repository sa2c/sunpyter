#!/bin/bash

module load anaconda
source activate
# This is a conda environment containing all Mahsa needs to run
conda activate /scratch/s.michele.mesiti/mahsa/conda

JUPYTER_PORT=8888

echo > $LOG

while [ $(ls $JUPYTER_PORT 2> /dev/null | wc -l) -gt 0 ]
do 
    echo "Port $JUPYTER_PORT is in use, trying next..."
    JUPYTER_PORT=$((JUPYTER_PORT+1))
done

echo "Using $JUPYTER_PORT on $(hostname)" 

echo "Start tunnel using:"
echo "ssh -L 8888:$(hostname):$JUPYTER_PORT -fN $USER@sunbird.swansea.ac.uk #TUNNELCOMMAND"

jupyter notebook --no-browser --port=$JUPYTER_PORT

