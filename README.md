This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

# Usage
*This would greatly benefit from having a ssh authenticator agent running
so that you don't have to put your password in too many times.*

From a terminal, use the command:
```bash
./sunpyter.sh  <your_sunbird_username>
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

## TODO 
- [ ] Make this work on Windows

