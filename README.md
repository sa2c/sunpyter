This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

# Preliminaries
- Windows: Make sure you have 
  the latest version of Git Bash 
  available.
  
- Set up your ssh key in advance. 


# Usage

1. From a terminal (or Git Bash on Windows),
   use the command:
   ```bash
   ./sunpyter.sh  <your_username_on_sunbird>
   ```
2. Type the passphrase for your key,
3. Wait
4. `sunpyter` will 
   either open a browser window 
   or give you a link 
   that you can copy and paste in a browser.
5. Do what you need to do 
6. At the end, 
   to make sure that 
   the resources on Sunbird are released,
   press `Ctrl+C` in the terminal window.

# Inner workings
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

At the end (see `cleanup.sh`):
- the remote slurm job is canceled
- the ssh processes are killed 
- the ssh agent is killed
