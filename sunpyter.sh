#!/bin/bash --login
set -eu
source ./find_resources.sh
source ./cleanup.sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 <your_sunbird_username>"
    exit
fi
REMOTE=$1@sunbird.swansea.ac.uk
JUPYTER_LOG=jupyter_log.txt # for scraping
SSH_MASTER_SOCKET=$(find_free_ssh_socket)
echo "Free socket for ssh_master: ${SSH_MASTER_SOCKET}"

###############
# Cleaning up #
###############

trap cleanup EXIT #SIGINT SIGHUP

start_jupyter_and_write_log(){
    local REMOTE=$1
    local JUPYTER_LOG=$2
    ssh -4 -S ${SSH_MASTER_SOCKET} -M $REMOTE 'bash -s' < <(sed 's/\r//' remote_script.sh) &> $JUPYTER_LOG &
}

start_jupyter_and_write_log $REMOTE $JUPYTER_LOG

echo "Waiting for jupyter notebook to start on server..."

printf "Waiting..."

wait_for_jupyter_server_to_start(){
    local JUPYTER_LOG=$1
    local RUNNINGCONFIRMATIONSTRING="Use Control-C to stop this server and shut down all kernels (twice to skip confirmation)."
    while [ $(grep $RUNNINGCONFIRMATIONSTRING $JUPYTER_LOG 2>/dev/null | wc -l ) -eq 0 ]
    do
      sleep 1
      printf .
    done
}

wait_for_jupyter_server_to_start $JUPYTER_LOG

echo "Launched."

echo "Output from the server:"
echo "========================================================================"
cat $JUPYTER_LOG
echo "========================================================================"

# We have a running jupyter notebook server, hooray!
##############################################################
# SCRAPING THE OUTPUT OF THE COMMAND TO FIND CONNECTION INFO #
##############################################################

# The command to create the tunnel contains the host and the port, and that 
# comes from the script running on sunbird.

# This 'purification' is needed to prevent grep from misreading the file
LINE=$(cat jupyter_log.txt | tr -d '\000' | grep -A 1 "The Jupyter Notebook is running at:" | tail -n 1)

REMOTE_HOST_AND_PORT=$(echo $LINE | sed -E 's|.*http://(.*)/\?token=([0-9a-f]+)$|\1|')
AUTH_TOKEN=$(echo $LINE | sed -E 's|.*http://(.*)/\?token=([0-9a-f]+)$|\2|')

#############################
# Finding a free local port #
#############################

JUPYTER_LOCAL_PORT=$(get_free_local_port)

echo "Using local port $JUPYTER_LOCAL_PORT"

################################
# Starting SSH port forwarding #
################################

echo "Creating ssh tunnnel:"
echo ssh -S ${SSH_MASTER_SOCKET} -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE
ssh -S ${SSH_MASTER_SOCKET} -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE

# chosing program to open link.
find_program_to_open_link(){
    local OPEN=""
    if which open &> /dev/null
    then
        echo open
    elif which xdg-open &> /dev/null
    then
        echo xdg-open
    else
        echo
    fi
}

OPEN=$(find_program_to_open_link)

echo "Found program: $OPEN"

if which $OPEN &> /dev/null
then
echo "Opening link..."
echo $OPEN "http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN"
$OPEN "http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN"
fi

echo "If nothing happens, copy and paste this link in your browser:"
echo
echo http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN
echo
echo REMEMBER: TERMINATE YOUR JOB WITH CTRL+C WHEN YOU ARE DONE.
echo

wait
