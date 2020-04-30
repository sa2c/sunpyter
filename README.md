This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

## Example usage
From a terminal, use the command:
```bash
./sunpyter.sh s.michele.mesiti@vnc.sunbird.swansea.ac.uk shellsetup_example.sh compute
```
`sunpyter.sh` executes some code on the remote 
machine (here, `vnc.sunbird.swansea.ac.uk`), parses the output of that command,
starts a ssh tunnel and opens a web page using eiter the `xdg-open` (linux?) or
`open` (mac?) command.

### Compute vs Login
The command 
```
./sunpyter.sh s.michele.mesiti@vnc.sunbird.swansea.ac.uk shellsetup_example.sh compute
```
starts a jupyter notebook server on a compute node via `sbatch`.
The command 
```
./sunpyter.sh s.michele.mesiti@vnc.sunbird.swansea.ac.uk shellsetup_example.sh login
```
starts a jupyter notebook server on the login node. 
The command launched with the `login` argument does not currently work on 
`sunbird.swansea.ac.uk`, but works on `vnc.sunbird.swansea.ac.uk`.

## Conda and remote setup

The code executed on the remote machine starts a jupyter notebook in the home 
directory, using a provisional conda environment created only for demonstration
purposes.

The files `launch_jupyter_preamble.sh`, the "shell setup" script passed as the 
second argument, and one between `launch_jupyter_login.sh` and 
`launch_jupyter_compute.sh` are concatenated together and executed on the 
remote node via ssh.

By passing another file instead of `shellsetup_example.sh` as a command line 
argument, a user can change the conda environment and the working directory. 
The slurm partition used in `compute` mode can be changed in the 
`launch_jupyter_compute.sh` script. 


## TODO 
- [ ] Make sure it works on Mac
- [ ] How to make this work on Windows? Do we care?
- [ ] The `login` mode does not work on sl1 and sl2, only on vnc - to investigate.
- [ ] The `--ip=*` option for jupyter notebook seemed to be necessary, but is 
      regarded as dangerous - to investigate.
- [ ] Add mechanism to kill remote notebook when the master script 
      (`sunpyter.sh`) exits (if the user clicks "quit" it's ok, otherwise it 
      will keep running!)
- [x] Add mechanism to run on a compute node

