#!/usr/bin/env bash
set -euo pipefail

echo "+================================================+"
echo "+ This script runs diagnostic tests for sunpyter.+"
echo "+ It also explain things step by step.           +"
echo "+ Feel free to ignore the pedantic tone.         +"
echo "+================================================+"
echo
echo "For the subsequent tests, we need your SuperComputingWales username."
echo "Please type it below:"
read SCW_USERNAME

export REMOTE=$SCW_USERNAME@sunbird.swansea.ac.uk

source ./testlib.sh

test_not_on_login_nodes &&
test_ssh_agent &&
test_ssh_socket_creation &&
(
    echo 
    echo "#####################################"
    echo "# Testing ways of checking ports... #"
    echo "#####################################"
    (test_ssHtan && echo "Other ways will not be tested") ||
    (test_lsofi && echo "Other ways will not be tested") ||
    (test_netstatan && echo "Other ways will not be tested") 
)
