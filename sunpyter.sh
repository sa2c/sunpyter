#!/bin/bash --login
set -eu

if [ $# -ne 1 ]
then
    echo "Usage: $0 <your_sunbird_username>"
    exit
fi
REMOTE=$1@sunbird.swansea.ac.uk
# for scraping
JUPYTER_LOG=jupyter_log.txt

find_free_ssh_socket(){
    local ISOCKET=1 
    SSH_SOCKET=/tmp/.ssh-sunpyter.$ISOCKET
    while [ -S "$SSH_SOCKET" ]
    do
      ISOCKET=$((ISOCKET+1))
      SSH_SOCKET=/tmp/.ssh-sunpyter.$ISOCKET
    done
    echo $SSH_SOCKET
}

SSH_MASTER_SOCKET=$(find_free_ssh_socket)
echo "Free socket for ssh_master: ${SSH_MASTER_SOCKET}"
cleanup(){
    echo
    echo "====================="
    echo "==     CLEANUP     =="
    echo "====================="
    export SLURMJOB=$(cat $JUPYTER_LOG | tr -d '\000' | grep "Submitted batch job" | awk '{print $4}' 2> /dev/null)
    if [ ! -z "${SLURMJOB}" ]
    then
        echo "Remote Slurm-Jupyter Job: $SLURMJOB"
    else
        echo "Remote Slurm-Jupyter Job: None"
    fi
   
    export JUPYTER_PROCESS=$(cat $JUPYTER_LOG | tr -d '\000' | grep "JUPYTER_PROCESS" | awk '{print $2}' 2> /dev/null)

    if [ ! -z "${JUPYTER_PROCESS}" ]
    then
        echo "Remote Jupyter process: $JUPYTER_PROCESS"
    else
        echo "Remote Jupyter process: None"
    fi

    # Kill remote job on sunbird
    if ! [ -z "$SLURMJOB" ]
    then 
        echo ssh -S ${SSH_MASTER_SOCKET} $REMOTE \"scancel $SLURMJOB\" 
        ssh -S ${SSH_MASTER_SOCKET} $REMOTE "scancel $SLURMJOB" 
    fi
    if ! [ -z "$JUPYTER_PROCESS" ]
    then 
        echo ssh -S ${SSH_MASTER_SOCKET} $REMOTE \"kill $JUPYTER_PROCESS\" 
        ssh -S ${SSH_MASTER_SOCKET} $REMOTE "kill $JUPYTER_PROCESS" 
    fi

    ssh -S ${SSH_MASTER_SOCKET} -O exit $REMOTE
    
}

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

get_free_local_port(){
    
    local FREE_LOCAL_PORT=8888  # Start from this one 
    
    # different machines can have different commands for this
    source ./check_port_uses.sh
    
    # iterating until we find a free port.
    while [ $(check_port_uses $FREE_LOCAL_PORT ) -gt 0 ]
    do 
      echo "Port $FREE_LOCAL_PORT is in use, trying next..." 1>&2
      FREE_LOCAL_PORT=$((FREE_LOCAL_PORT + 1))
    done
    echo $FREE_LOCAL_PORT
}

JUPYTER_LOCAL_PORT=$(get_free_local_port)

echo "Using local port $JUPYTER_LOCAL_PORT"

################################
# Starting SSH port forwarding #
################################

echo "Creating ssh tunnnel:"
echo ssh -S ${SSH_MASTER_SOCKET} -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE
ssh -S ${SSH_MASTER_SOCKET} -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE

# chosing program to open link.
OPEN=""
which open &> /dev/null && OPEN=open 
[ -z "$OPEN" ] && which xdg-open &> /dev/null && OPEN=xdg-open

echo "Opening link..."
#$OPEN http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN
echo "If nothing happens, copy and paste this link in your browser:"
echo http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN

###############
# Cleaning up #
###############

wait
