This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

## Example usage
From a terminal, use the command:
```bash
./master_script s.michele.mesiti@vnc.sunbird.swansea.ac.uk compute
```
`master_script.sh` executes some code on the remote 
machine (here, `vnc.sunbird.swansea.ac.uk`), parses the output of that command,
starts a ssh tunnel and opens a web page using eiter the `xdg-open` (linux?) or
`open` (mac?) command.

### Compute vs Login
The command 
```
./master_script s.michele.mesiti@vnc.sunbird.swansea.ac.uk compute
```
starts a jupyter notebook server on a compute node via `sbatch`.
The command 
```
./master_script s.michele.mesiti@vnc.sunbird.swansea.ac.uk login
```
starts a jupyter notebook server on the login node. 
The command launched with the `login` argument does not currently work on 
`sunbird.swansea.ac.uk`, but works on `vnc.sunbird.swansea.ac.uk`.

## Conda and remote setup

The code executed on the remote machine starts a jupyter notebook in the home 
directory, using a provisional conda environment created only for demonstration
purposes.

By modifying the `launch_jupyter_preamble.sh` file, a user can change the conda
environment, the working directory and the slurm partition used in `compute` 
mode.

## TODO 
- [ ] Make sure it works on Mac
- [ ] How to make this work on Windows? Do we care?
- [ ] The `login` mode does not work on sl1 and sl2, only on vnc - to investigate.
- [ ] The `--ip=*` option for jupyter notebook seemed to be necessary, but is 
      regarded as dangerous - to investigate.
- [ ] Add mechanism to kill remote notebook when the master script exits
      (if the user clicks "quit" it's ok, otherwise it will keep running!)
- [x] Add mechanism to run on a compute node


