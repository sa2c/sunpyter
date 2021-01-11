#!/usr/bin/env bash
set -eu

# Needs:
# - JUPYTER_LOG
# - SSH_MASTER_SOCKET
# - REMOTE
# - SSH_AGENT_PID
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

    if [ $SUNPYTER_SSH_AGENT == "true" ]
    then
        echo "Terminating our ssh agent:"
        echo kill ${SSH_AGENT_PID}
        kill ${SSH_AGENT_PID}
    fi
    echo
    echo "====================="
    echo "==  CLEANUP  DONE  =="
    echo "== HAVE A NICE DAY =="
    echo "====================="
    
}
