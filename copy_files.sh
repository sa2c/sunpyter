#!/usr/bin/env bash
set -euo pipefail

echo "+===============================================+"
echo "+This script will copy the files                +"
echo "+from the shared directories on the CDT storage +"
echo "+to your home directory on thie CDT storage.    +"
echo "+===============================================+"

echo "For the subsequent operations, we need your SuperComputingWales username."
echo "Please type it below:"
read SCW_USERNAME
CDT_LOGIN=137.44.249.154
export REMOTE=$SCW_USERNAME@$CDT_LOGIN


cat > copy_files_remote.sh <<SCRIPT_CONTENT
for DATA_DIR in ChanceToShine
do
    echo cp -r ../\$DATA_DIR ~/\$DATA_DIR
    cp -r ../\$DATA_DIR ~/\$DATA_DIR
done
SCRIPT_CONTENT

echo "Copying data... "
echo "You may required to type your password."
ssh $REMOTE 'bash -s ' < copy_files_remote.sh
