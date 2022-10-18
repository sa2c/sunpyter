# Sunpyter Internals

`sunpyter.sh` does the following:
- starts a ssh agent and asks you to add your keys to the agent
  (this is necessary to make sure 
  you don't have to type your password 
  every time, especially during tear down).
  The key is assumed to be `.ssh/id_rsa`.
- finds a free socket for the ssh master connection.
- starts the jupyter notebook server on a remote machine with a ssh command, creating the ssh master socket.
- parses the output of that command, collecting:
  * the SLURM job ID number
  * the remote port on which the jupyter notebook server is running
  * the access token that is used to access the jupyter notebook server
- starts a ssh tunnel using the same master socket
- linux and MacOS only: opens a web page 
  pointing at the jupyter notebook 
  (using the authentication tokens provided by the server when it is starting).
- Windows only: gives you a link,
  to open in your browser.

At the end, when you press `CTRL+C` (see `cleanup.sh`):
- the remote slurm job is canceled
- the ssh processes are killed 
- the ssh agent is killed
