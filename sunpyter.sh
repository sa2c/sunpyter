#!/bin/bash --login

if [ $# -ne 1 ]
then
    echo "Usage: $0 <your_sunbird_username>"
    exit
fi

REMOTE=$1
JUPYTER_LOG=jupyter_log.txt

start_jupyter_and_write_log(){
    local REMOTE=$1
    local JUPYTER_LOG=$2
    ssh $REMOTE 'bash -s' < remote_script.sh &> $JUPYTER_LOG &
    
}

start_jupyter_and_write_log $REMOTE $JUPYTER_LOG

get_ssh_process_id(){
    local REMOTE=$1
    local SSHPROC=$( ps -ef | grep ssh | grep $REMOTE | grep bash | grep -v grep | awk '{print $2}'| sort -n | tail -n 1)
    echo $SSHPROC
    
}

SSHPROC=$(get_ssh_process_id $REMOTE)

echo SSHPROC=$SSHPROC
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
############################################################
# MINING THE OUTPUT OF THE COMMAND TO FIND CONNECTION INFO #
############################################################

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
    
  JUPYTER_LOCAL_PORT=8888  # Start from this one 
  
  # different machines can have different commands for this
  check_port_uses(){

    local PORT=$1

    check_port_ss(){
      ss -Htan | awk '{print $4}' | cut -d':' -f2 | grep $PORT 2> /dev/null | wc -l
    }
    
    check_port_lsof(){
      lsof -i :$PORT 2>/dev/null | wc -l
    }

    check_port_lsof || check_port_ss
  }
  
  # iterating until we find a free port.
  while [ $(check_port_uses $JUPYTER_LOCAL_PORT ) -gt 0 ]
  do 
    echo "Port $JUPYTER_LOCAL_PORT is in use, trying next..."
    JUPYTER_LOCAL_PORT=$((JUPYTER_LOCAL_PORT + 1))
  done
}

get_free_local_port

echo "Using local port $JUPYTER_LOCAL_PORT"

################################
# Starting SSH port forwarding #
################################

echo "Creating ssh tunnnel:"
echo "ssh -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE"
ssh -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE
SSHTUNNELPROC=$( ps -ef | grep ssh | grep $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT | grep -v grep | awk '{print $2}')
echo SSHTUNNELPROC=$SSHTUNNELPROC

# chosing program to open link.
which open &> /dev/null && OPEN=open 
[ -z "$OPEN" ] && which xdg-open &> /dev/null && OPEN=xdg-open

echo "Opening link..."
$OPEN http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN
echo "If nothing happens, copy and paste this link in your browser:"
echo http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN

###############
# Cleaning up #
###############

cleanup(){
    export SLURMJOB=$(cat jupyter_log.txt | tr -d '\000' | grep "Submitted batch job" | awk '{print $4}' 2> /dev/null)
    echo "SLURM JOB:$SLURMJOB"
    
    export JUPYTER_PROCESS=$(cat jupyter_log.txt | tr -d '\000' | grep "JUPYTER_PROCESS" | awk '{print $2}' 2> /dev/null)
    echo "JUPYTER_PROCESS: $JUPYTER_PROCESS"

    echo "Sumpyter job:$SLURMJOB"
    # Kill remote job on sunbird
    if ! [ -z "$SLURMJOB" ]
    then 
        echo ssh $REMOTE "scancel $SLURMJOB"
        ssh $REMOTE "scancel $SLURMJOB" 
    fi
    if ! [ -z "$JUPYTER_PROCESS" ]
    then 
        echo ssh $REMOTE "kill $JUPYTER_PROCESS"
        ssh $REMOTE "kill $JUPYTER_PROCESS" 
    fi
 
    echo kill $SSHPROC 
    echo kill $SSHTUNNELPROC
    kill $SSHPROC
    kill $SSHTUNNELPROC
    
}

trap cleanup EXIT SIGINT SIGHUP

wait
