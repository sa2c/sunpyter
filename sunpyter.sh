#!/bin/bash

if [ $# -lt 3 ]
then
    echo "Usage: $0 <remote> <shell setup script> <run mode>"
    echo "e.g.:"
    echo "$0 s.michele.mesiti@sunbird.swansea.ac.uk shellsetup_example.sh compute #EXAMPLE"
    exit
fi

REMOTE=$1 # e.g. s.michele.mesiti@vnc.sunbird.swansea.ac.uk
SHELLSETUP=$2
USE_LOGIN=$3

if [ -z "$REMOTE" ]
then 
    echo "Please give a remote, e.g. username@vnc.sunbird.swansea.ac.uk"
    exit
fi

if [ "$USE_LOGIN" == "compute" ]
then 
    LAUNCH_JUPYTER_COMMAND=launch_jupyter_compute.sh
elif [ "$USE_LOGIN" == "login" ]
then
    LAUNCH_JUPYTER_COMMAND=launch_jupyter_login.sh
else
    echo 'Wrong launch specification, use either "login" or "compute".'
    exit
fi

ssh $REMOTE 'bash -s' < <( cat launch_jupyter_preamble.sh "$SHELLSETUP" "$LAUNCH_JUPYTER_COMMAND") &> jupyter_log.txt &

echo "Waiting for jupyter notebook to start on server..."


RUNNINGCONFIRMATIONSTRING="Use Control-C to stop this server and shut down all kernels (twice to skip confirmation)."


printf "Waiting..."
while [ $(grep $RUNNINGCONFIRMATIONSTRING jupyter_log.txt 2>/dev/null | wc -l ) -eq 0 ]
do
    sleep 1
    printf .
done
echo "Launched."

echo "Output from the server:"
echo "========================================================================"
cat jupyter_log.txt
echo "========================================================================"

echo "Creating ssh tunnnel:"
# The command to create the tunnel contains the host and the port, and that 
# comes from the script running on sunbird.

# This 'purification' is needed to prevent grep from misreading the file
LINE=$(cat jupyter_log.txt | tr -d '\000' | grep -A 1 "The Jupyter Notebook is running at:" | tail -n 1)

REMOTE_HOST_AND_PORT=$(echo $LINE | sed -E 's|.*http://(.*)/\?token=([0-9a-f]+)$|\1|')
AUTH_TOKEN=$(echo $LINE | sed -E 's|.*http://(.*)/\?token=([0-9a-f]+)$|\2|')


# Finding a free local port
JUPYTER_LOCAL_PORT=8888
while [ $(ss -Htan | awk '{print $4}' | cut -d':' -f2 | grep $JUPYTER_LOCAL_PORT 2>/dev/null | wc -l) -gt 0 ]
do 
    echo "Port $JUPYTER_LOCAL_PORT is in use, trying next..."
    JUPYTER_LOCAL_PORT=$((JUPYTER_LOCAL_PORT+1))
done
echo "Using local port $JUPYTER_LOCAL_PORT"

echo "ssh -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE"
ssh -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE

# chosing program to open link
which open &> /dev/null && OPEN=open 
[ -z "$OPEN" ] && which xdg-open &> /dev/null && OPEN=xdg-open

echo "Opening link..."
echo $OPEN http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN
$OPEN http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN

wait
