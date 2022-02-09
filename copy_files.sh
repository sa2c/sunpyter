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
CDT_LOGIN=sa2c-backup2.swansea.ac.uk
export REMOTE=$SCW_USERNAME@$CDT_LOGIN

cat > copy_files_remote.sh <<SCRIPT_CONTENT
# TODO: UPDATE THIS WHEN MORE CHARITIES ARE AVAILABLE
for DATA_DIR in sericc
do
    if [ ! -d  ~/\$DATA_DIR ]
    then
        echo cp -r /cdt_storage/\$DATA_DIR ~/\$DATA_DIR
        cp -r /cdt_storage/\$DATA_DIR ~/\$DATA_DIR
        # Making sure the copied data
        # is not overwritten or changed.
        chmod a-w ~/\$DATA_DIR
    else
        echo "Directory" \$DATA_DIR "already copied."
    fi
done
SHARED=~/shared
if [ ! -d \$SHARED ]
then
    echo ln -s /cdt_storage/scw1738 \$SHARED
    ln -s /cdt_storage/scw1738 \$SHARED
else
    echo "Shared directory already linked."
fi
SCRIPT_CONTENT

echo "Copying data... "
echo "You may required to type your password."
ssh $REMOTE 'bash -s ' < copy_files_remote.sh
