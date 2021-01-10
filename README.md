This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

# Preliminaries
 
## Set up the SSH keys
  Set up your ssh key in advance. 
  This may require using `ssh-keygen` 
  to create a public-private key pair 
  (if you haven't already)
  and `ssh-copy-id` to install the public key to sunbird.
  
### More detailed instructions
  - Check if you have the files `~/.ssh/id_rsa`
    and  `~/.ssh/id_rsa.pub`.
    ("`~`" represents your home directory, 
    in the Bash jargon).
    **Only if these two files DO NOT exist**,
    generate a public-private key pair with
    ```
    ssh-keygen -t rsa 
    ```
    Follow the instructions on screen,
    and remember the passphrase.
  - Install the key on the remote machine.
    This step is safe.
    ```
    ssh-copy-id <your-username>@sunbird.swansea.ac.uk
    ``` 
    If you have already done that, 
    you will get a message 
    telling you that the keys already exist on the remote system.

## Have your HOME created on the CDT storage
  Make sure your home directory on the cdt storage is created. 
  This happens when you log in the first time on the CDT storage login node. 

## Use the CDT branch
 Make sure you check out the `CDT` branch, not `master`.

## Notes on **Windows**
  Make sure you have 
  the latest version of Git Bash 
  available.

# Test your system first.
  A bunch of tests 
  to make sure that `sunpyter` can run correctly 
  is contained in the script `test.sh`.
  Please run that first.

# Usage

0. Run `test.sh` 
   and please follow the messages on screen.
   Please report anything suspicious.
1. From a terminal (or Git Bash on Windows),
   use the command:
   ```bash
   ./sunpyter.sh  <your_username_on_sunbird>
   ```
2. Type the passphrase for your ssh key,
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
   Pressing the "Quit" button is also a good idea.
   

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

At the end, when you press `CTRL+C` (see `cleanup.sh`):
- the remote slurm job is canceled
- the ssh processes are killed 
- the ssh agent is killed

# Notes
Tested on:
- Arch linux,
  - Bash 5.0.18, 
  - openSSH8.4p1, OpenSSL1.1.1h, 22 Sep 2020
- Git Bash
  - Bash 4.4.23, 
  - openSSH8.4p1, OpenSSL1.1.1h, 22 Sep 2020
   
# Troubleshooting
  * **The script takes a long time "Waiting..." and nothing happens.**
    It can take a couple of minutes. 
    After that, you might have to ssh into `sunbird` 
    and check the output of `squeue -u $USER`.
    Notice: you can have only one jupyter job running on Sunbird.
    If an old jupyter job of yours is still running, 
    you will not be able to start a new one. 
    Use `scancel` to kill the old one.
  * **I get ERROR: /cdt_storage/<my_username> does not exist.**
    You need to log into the CDT storage log in node 
    to have your home directory created first.
  * **It does not work with the Windows Subsystem for Linux**
    This is a known issue, sorry. 
    Use Git Bash instead.
