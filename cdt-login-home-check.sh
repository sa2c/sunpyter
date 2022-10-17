#!/usr/bin/env bash
set -euo pipefail

ACCOUNT=scw1000
HOMEDIR=/home/$USER

cat > job_script.sh <<SCRIPT_CONTENT
#!/bin/bash
if [ -d $HOMEDIR ]
then
    echo "Ok, your home directory in the CDT storage exists."
else
    echo "ERROR: $HOMEDIR does not exist."
    echo "ERROR: Make sure you do the necessary steps to create it first."
    exit 1
fi
SCRIPT_CONTENT

srun -A $ACCOUNT \
    --partition accel_ai \
    -o $LOG \
    -J SUNPYTER_$USER \
    --dependency=singleton \
    -n 1 \
    --gres=gpu:1 \
    --oversubscribe \
    bash job_script.sh
