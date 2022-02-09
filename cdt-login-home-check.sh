#!/usr/bin/env bash
set -euo pipefail


ACCOUNT=scw1738
HOMEDIR=/cdt_storage/$USER

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

srun --partition s_highmem_cdt \
    -A $ACCOUNT \
    -n 1 \
    -t 1 \
    --oversubscribe \
    bash job_script.sh
