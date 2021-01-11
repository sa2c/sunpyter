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

test_cdt_branch &&
test_ssh_agent &&
test_ssh_socket_creation &&
(
    test_ssHtan ||
    test_lsofi || 
    test_netstatan
)
