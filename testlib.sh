#!/usr/bin/env bash

test_cdt_branch(){
    echo
    echo "======================================================"
    echo "Testing that we are on the CDT branch"
    echo "(which should be true, otherwise you couldn't see this)"
    echo "======================================================"
    BRANCH=$(git status | grep "On branch" | cut -d' ' -f3)
    if [ $BRANCH == "CDT" ]
    then
        echo "Test successful"
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
    ssh $SUNBIRD_USERNAME@sunbird.swansea.ac.uk "echo Connected, hopefully without password."
}

test_ssh_socket_creation(){
    echo
    echo "======================================================"
    echo "Testing ssh socket creation"
    echo "======================================================"
    source ./find_resources.sh
    SSH_SOCKET=$(find_free_ssh_socket)
    echo "Trying with socket: ${SSH_SOCKET}"
    ssh -S ${SSH_SOCKET} -M $SUNBIRD_USERNAME@sunbird.swansea.ac.uk "sleep 15; echo Remote process done." &> test_log.txt &
    sleep 5
    if [ -S ${SSH_SOCKET} ]
    then
        echo "SSH socket created, wait 10 seconds..."
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
    ss -Htan > /dev/null  && echo "Test was successful" || (
            echo "ss -Htan does not work on your system"
            echo "you may still be ok if lsof or netstat work."
        )
}

test_lsofi(){
    echo
    echo "======================================================"
    echo "Testing whether lsof is present on your system"
    echo "and accepts the right options"
    echo "======================================================"
    lsof -i :8888 > /dev/null  && echo "Test was successful" || (
            echo "lsof -i :<port number> does not work on your system"
            echo "you may still be ok if ss or netstat work."
        )
}

test_netstatan(){
    echo
    echo "======================================================"
    echo "Testing whether netstat is present on your system"
    echo "and accepts the right options"
    echo "======================================================"
    netstat -an > /dev/null  && echo "Test was successful" ||  (
            echo "netstat -an does not work on your system"
            echo "you may still be ok if ss or lsof work."
        )
}

