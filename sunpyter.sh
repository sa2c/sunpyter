#!/bin/bash --login
set -eu
source ./find_resources.sh
source ./cleanup.sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 <your_sunbird_username>"
    exit
fi
trap cleanup EXIT

USERNAME=$1
REMOTE=$USERNAME@sunbird.swansea.ac.uk

setup_ssh_agent(){
    echo > .ssh_agent_setup
    export SUNPYTER_SSH_AGENT='false'
    ssh -oBatchMode=yes $REMOTE "echo Passwordless access to Sunbird correctly set up." || (
        echo "Creating new ssh agent" 
        ssh-agent > .ssh_agent_setup # sets SSH_AGENT_PID
        echo "export SUNPYTER_SSH_AGENT=true" >> .ssh_agent_setup
        source .ssh_agent_setup
        ssh-add ~/.ssh/id_rsa
    )
    source .ssh_agent_setup
}

setup_ssh_agent

JUPYTER_LOG=jupyter_log.txt # for scraping
SSH_MASTER_SOCKET=$(find_free_ssh_socket)
echo "Free socket for ssh_master: ${SSH_MASTER_SOCKET}"

start_jupyter_and_write_log(){
    local REMOTE=$1
    local JUPYTER_LOG=$2
    local REMOTE_SCRIPT=$3
    ssh -S ${SSH_MASTER_SOCKET} -M $REMOTE 'bash -s' < $REMOTE_SCRIPT &> $JUPYTER_LOG &
    sleep 5 # BODGE - wait for the ssh socket to be created
}

start_jupyter_and_write_log $REMOTE $JUPYTER_LOG remote_script.sh

if [ -S ${SSH_MASTER_SOCKET} ]
then
    echo "SSH socket created..."
else
    echo "SSH Socket creation failed: exiting"
    exit
fi

echo "Waiting for jupyter notebook to start on server..."

printf "Waiting..."

check_for_errors(){
    FILE=$1
    grep ERROR $FILE
}

wait_for_jupyter_server_to_start(){
    local JUPYTER_LOG=$1
    local RUNNINGCONFIRMATIONSTRING="Use Control-C to stop this server and shut down all kernels (twice to skip confirmation)."
    while [ $(grep $RUNNINGCONFIRMATIONSTRING $JUPYTER_LOG 2>/dev/null | wc -l ) -eq 0 ]
    do
      if [ $(check_for_errors $JUPYTER_LOG | wc -l) -ne 0 ] 
      then 
        echo # new line for readability
        check_for_errors $JUPYTER_LOG 
        exit
      fi 
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
LINE=$(cat jupyter_log.txt | tr -d '\000' | grep -A 1 -E "Jupyter\s*Notebook.*is\s*running\s*at:" | tail -n 1) 

echo Log Line with connection information:
echo $LINE

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
        if [ $(open --help | grep "(VT)" | wc -l ) -eq 0 ]
        then 
            echo open
        else
            # then 'open' might refer to a tool 
            # which has nothing to do with our aims.
            echo
        fi
    elif which xdg-open &> /dev/null
    then
        echo xdg-open
    else
        echo
    fi
}

OPEN=$(find_program_to_open_link)

if [ -z "$OPEN" ]
then 
   echo
   echo "No program found to open link"
   echo "please do it manually."
   echo
else
   echo
   echo "Found program: $OPEN"
   echo
fi

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
echo '                     REMEMBER:'
echo '              KEEP THIS TERMINAL OPEN.'
echo '                 WHEN YOU ARE DONE:'
echo ' CLICK ON THE "QUIT" BUTTON ON THE JUPYTER WEB INTERFACE.'
echo '        AND TERMINATE THIS PROCESS WITH CTRL+C.'
echo '      THEN YOU CAN CLOSE THE TERMINAL IF YOU WISH.'
echo

wait
