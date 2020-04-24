This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

## Example usage
From a terminal, use the command:
```bash
./master_script s.michele.mesiti@vnc.sunbird.swansea.ac.uk
```
`master_script.sh` executes the `launch_jupyter.sh` script on the remote 
machine (here, `vnc.sunbird.swansea.ac.uk`), parses the output of that command,
starts a ssh tunnel and opens a web page using eiter the `xdg-open` (linux?) or
`open` (mac?) command.

The `launch_jupyter.sh` script starts a jupyter notebook in the home 
directory, using a provisional conda environment that I created.

## TODO 
[ ] Make sure it works on Mac
[ ] Does not work on sl1 and sl2, only on vnc - to investigate.
[ ] The `--ip=*` option for jupyter notebook seemed to be necessary, but is 
    regarded as dangerous - to investigate.
[ ] Add mechanism to kill remote notebook when the master script exits
[ ] Add mechanism to run on a compute node


