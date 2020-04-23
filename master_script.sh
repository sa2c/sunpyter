#!/bin/bash

ssh sunbird 'bash -s' < launch_jupyter.sh &> jupyter_log.txt &
$(grep TUNNELCOMMAND  jupyter_log.txt) 

wait
