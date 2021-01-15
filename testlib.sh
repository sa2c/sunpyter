#!/usr/bin/env bash

test_not_on_login_nodes(){
    echo
    echo "======================================================"
    echo "Testing this is not running on the login nodes."
    echo "This (and sunpyter) should be running on your machine!"
    echo "======================================================"
    HOST=$(hostname)
    if [ $HOST == "sl1" ] || [ $HOST == "sl2" ]
    then
        echo "Test failed:"
        echo "You're running it on the Sunbird login nodes"
        return 1
    elif [ $HOST == "sa2c-backup2" ]
    then
        echo "Test failed:"
        echo "You're running it on the CDT storage login node"
        return 1
    else
        echo "Test successful:"
        echo "On $HOST"
    fi
}

test_cdt_branch(){
    echo
    echo "======================================================"
    echo "Testing that we are on the CDT branch"
    echo "(which should be true, otherwise you couldn't see this)"
    echo "======================================================"
    BRANCH=$(git status | grep "On branch" | awk '{print $NF}')
    if [ $BRANCH == "CDT" ]
    then
        echo "Test successful"
        echo "On branch $BRANCH"
    else
        echo "Test failed: on $BRANCH instead."
        return 1
    fi
}

test_ssh_agent(){
    echo
    echo "======================================================"
    echo "Testing ssh agent setup"
    echo "======================================================"
    echo "Creating ssh agent:"
    eval $(ssh-agent) 
    echo "Adding ~/.ssh/id_rsa to agent. You will be asked your key's passphrase:"
    ssh-add ~/.ssh/id_rsa
    echo "We'll now try to connect to sunbird.swansea.ac.uk"
    echo "If you are requested your SCW password, this test has failed."
    ssh $REMOTE "echo Connected, hopefully without password."
}

test_ssh_socket_creation(){
    echo
    echo "======================================================"
    echo "Testing ssh socket creation"
    echo "(this will take ~15 seconds)"
    echo "======================================================"
    source ./find_resources.sh
    SSH_SOCKET=$(find_free_ssh_socket)
    echo "Trying with socket: ${SSH_SOCKET}"
    ssh -S ${SSH_SOCKET} -M $REMOTE "sleep 15; echo Remote process done." &> test_log.txt &
    sleep 5
    if [ -S ${SSH_SOCKET} ]
    then
        echo "SSH socket created, wait ~10 seconds..."
        wait
        cat test_log.txt
        echo "Test was successful"
    else
        echo "SSH Socket creation failed: exiting"
        wait
        cat test_log.txt
        return 1
    fi

}

test_ssHtan(){
    echo
    echo "======================================================"
    echo "Testing whether ss is present on your system"
    echo "and accepts the right options"
    echo "======================================================"
    ss -Htan > /dev/null  && echo "Test was successful, ss command works" || (
            echo "ss -Htan does not work on your system"
            echo "you may still be ok if lsof or netstat work."
            return 1
        )
}

test_lsofi(){
    echo
    echo "======================================================"
    echo "Testing whether lsof is present on your system"
    echo "and accepts the right options"
    echo "======================================================"
    lsof -i :8888 > /dev/null  && echo "Test was successful, lsof command works" || (
            echo "lsof -i :<port number> does not work on your system"
            echo "you may still be ok if ss or netstat work."
            return 1
        )
}

test_netstatan(){
    echo
    echo "======================================================"
    echo "Testing whether netstat is present on your system"
    echo "and accepts the right options"
    echo "======================================================"
    netstat -an > /dev/null  && echo "Test was successful, netstat command works" ||  (
            echo "netstat -an does not work on your system"
            echo "you may still be ok if ss or lsof work."
            return 1
        )
}

