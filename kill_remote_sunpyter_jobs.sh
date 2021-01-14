#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 <your_sunbird_username>"
    exit
fi

REMOTE=$1@sunbird.swansea.ac.uk

cat > .remote_command.sh <<EOF
echo "Remote Jobs:"
squeue -u \$USER -n SUNPYTER -o %A | tail -n+2
scancel \$(squeue -u \$USER -n SUNPYTER -o %A | tail -n+2)
EOF

echo Launching command via ssh...
ssh $REMOTE 'bash -s ' < .remote_command.sh 
rm .remote_command.sh
