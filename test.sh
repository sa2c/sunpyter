#!/usr/bin/env bash
set -euo pipefail

echo "+================================================+"
echo "+ This script runs diagnostic tests for sunpyter.+"
echo "+ It also explain things step by step.           +"
echo "+ Feel free to ignore the pedantic tone.         +"
echo "+================================================+"
echo
echo "For the subsequent tests, we need your sunbird username."
echo "Please type it below:"
read SUNBIRD_USERNAME

source ./testlib.sh

test_cdt_branch &&
test_ssh_agent &&
test_ssh_socket_creation &&
(test_ssHtan ||
test_lsofi || 
test_netstatan )
