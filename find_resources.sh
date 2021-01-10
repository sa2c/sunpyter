#!/usr/bin/env bash

find_free_ssh_socket(){
    local ISOCKET=1 
    SSH_SOCKET=./.ssh-sunpyter.$ISOCKET
    while [ -S "$SSH_SOCKET" ]
    do
      ISOCKET=$((ISOCKET+1))
      SSH_SOCKET=./.ssh-sunpyter.$ISOCKET
    done
    echo $SSH_SOCKET
}

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
