#!/bin/bash --login

if [ $# -ne 1 ]
then
    echo "Usage: $0 <config>"
    exit
fi

CONFIG=$1
source $CONFIG

if [ -z "$REMOTE" ]
then 
    echo "Please give a remote, e.g. username@sunbird.swansea.ac.uk"
    exit
fi

if [ -z "$ACCOUNT" -a "$RUNWHERE" == "compute" ]
then 
    echo "Please give an account, e.g. your project name (scwXXXX)"
    exit
fi

if [ -z "$SHELLSETUP" ]
then 
    echo "Please give the name of a file containing the bash commands needed"
    echo "to set up the environment, e.g. the commands to:"
    echo "   1. Activate the right conda environment"
    echo "   2. Change directory to the right location before starting the"
    echo "      jupyter notebook process."
    echo "Please see example."
    exit
fi

if [ "$RUNWHERE" == "compute" ]
then 
    LAUNCH_JUPYTER_COMMAND=launch_jupyter_compute.sh
elif [ "$RUNWHERE" == "login" ]
then
    LAUNCH_JUPYTER_COMMAND=launch_jupyter_login.sh
else
    echo 'Wrong launch specification, use either "login" or "compute".'
    exit
fi

ssh $REMOTE 'bash -s' < <( cat launch_jupyter_preamble.sh "$SHELLSETUP" "$LAUNCH_JUPYTER_COMMAND" | sed 's/SEDACCOUNT/'$ACCOUNT'/') &> jupyter_log.txt &

SSHPROC=$( ps -ef | grep ssh | grep $REMOTE | grep bash | grep -v grep | awk '{print $2}'| sort -n | tail -n 1)
echo SSHPROC=$SSHPROC
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
JUPYTER_LOCAL_PORT=8888  # Start from this one 

# different machines can have different commands for this
CHECKPORTSS="ss -Htan | awk '{print \$4}' | cut -d':' -f2 | grep "
CHECKPORTLSOF="lsof -i :"

# Checking which command is available
which ss &> /dev/null && CHECKPORT="$CHECKPORTSS"
[ -z "$CHECKPORT" ] && which lsof &> /dev/null && CHECKPORT="$CHECKPORTLSOF"

# iterating until we find a free port.
while [ $( bash -s < <(echo "$CHECKPORT$JUPYTER_LOCAL_PORT") 2>/dev/null | wc -l) -gt 0 ]
do 
    echo "Port $JUPYTER_LOCAL_PORT is in use, trying next..."
    JUPYTER_LOCAL_PORT=$((JUPYTER_LOCAL_PORT+1))
done

echo "Using local port $JUPYTER_LOCAL_PORT"

################################
# Starting SSH port forwarding #
################################

echo "Creating ssh tunnnel:"
echo "ssh -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -fN $REMOTE"
ssh -L $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT -N $REMOTE
SSHTUNNELPROC=$( ps -ef | grep ssh | grep $JUPYTER_LOCAL_PORT:$REMOTE_HOST_AND_PORT | grep -v grep | awk '{print $2}')
echo SSHTUNNELPROC=$SSHTUNNELPROC


# chosing program to open link.
which open &> /dev/null && OPEN=open 
[ -z "$OPEN" ] && which xdg-open &> /dev/null && OPEN=xdg-open

echo "Opening link..."
echo $OPEN http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN
$OPEN http://localhost:$JUPYTER_LOCAL_PORT/?token=$AUTH_TOKEN

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
