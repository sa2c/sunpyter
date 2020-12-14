This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

# Usage
*This would greatly benefit from having a ssh authenticator agent running,
so that you don't have to put your password in too many times.*

From a terminal, use the command:
```bash
./sunpyter.sh config.sh
```
`sunpyter.sh` does the following:
- starts the jupyter notebook server on a remote machine
- parses the output of that command, collecting:
  * the SLURM job ID number
  * the remote port on which the jupyter notebook server is running
  * the access token that is used to access the jupyter notebook server
- starts a ssh tunnel and opens a web page pointing at the 
  jupyter notebook (using the authentication tokens provided by the server
  when it is starting).

## Config file
A config file must be provided, which defines a number of environment 
variables. See `config_example.sh`, for an inspiration:
```bash
REMOTE=s.michele.mesiti@vnc.sunbird.swansea.ac.uk # Username&host, or alias
SHELLSETUP=shellsetup_example.sh # see example
RUNWHERE=compute # either 'compute' or 'login'
ACCOUNT=scw1000 # account to run the job on for the jupyter notebook.
```
### `REMOTE`
The `REMOTE` variable is used throughout `sunpyter.sh` as the destination of 
all ssh connections.

### `RUNWHERE`: Compute vs Login
In the config file, the `RUNWHERE` environment variable can be set either
to `login` or `compute`. With `compute`, `sunpyter.sh` starts a jupyter notebook 
server on a compute node via `sbatch` (using the `launch_jupyter_compute.sh` 
script).
With `login`, `sunpyter.sh` starts a jupyter notebook server on the login node
(using the `launch_jupyter_login.sh` script).

NOTE: The `login` option does not currently work with `sunbird.swansea.ac.uk`, 
but works with `vnc.sunbird.swansea.ac.uk`.

### `SHELLSETUP`: Conda and remote setup

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

### `ACCOUNT`
When `RUNWHERE` is set to `compute`, a slurm account is needed to launch the
jupyter notebook on a compute node.

# Notes
The `launch_jupyter_preamble.sh` script, the `$SHELLSETUP` and the 
`launch_jupyter_compute.sh` (or the `launch_jupyter_login.sh`) scripts are collated 
into a single ssh script and executed on Sunbird login nodes in the first ssh invocation.



## TODO 
- [x] Make sure it works on Mac
- [ ] How to make this work on Windows? Do we care?
- [ ] The `login` mode does not work on sl1 and sl2, only on vnc - to investigate.
- [ ] The `--ip=*` option for jupyter notebook seemed to be necessary, but is 
      regarded as dangerous - to investigate.
- [x] Add mechanism to run on a compute node
- [x] Add mechanism to kill remote notebook job on a *compute* node when the master 
      script (`sunpyter.sh`) exits (if the user clicks "quit" it's ok, otherwise it 
      will keep running!)
- [x] Add mechanism to kill remote notebook job on a login node in the same 
      situation

