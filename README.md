This is a small collection of shell scripts that should allow running
jupyter notebooks on Sunbird without much effort.

# Preliminaries
- Set up the SSH keys
  Set up your ssh key in advance. 
  This may require using `ssh-keygen` 
  to create a public-private key pair 
  (if you haven't already)
  and `ssh-copy-id` to install the public key to sunbird.
  
  For more detailed instructions,
  see the [SSH keys guide](ssh-keys-guide.md). 

- Have your HOME created on the CDT storage
  Make sure your home directory on the cdt storage is created. 
  This happens when you log in the first time on the CDT storage login node. 

- Use the CDT branch
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
  If you encounter problems,
  look at the Troubleshooting section of this guide.

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
5. Do what you need to do, but **do not close the terminal yet**.
6. At the end, 
   to make sure that 
   the resources on Sunbird are released,
   press `Ctrl+C` in the terminal window.
   Pressing the "Quit" button is also a good idea.
7. You can now close the terminal,
   if you want.

# Troubleshooting
  * **test.sh fails while testing being on the CDT branch**
    Make sure you are not running `test.sh` 
    on Sunbird. 
    `test.sh` and `sunpyter.sh`
    must be run on your home machine.T
  * **The script takes a long time "Waiting..." and nothing happens.**
    It can take a couple of minutes. 
    After that, you might have to ssh into `sunbird` 
    and check the output of `squeue -u $USER`.
    Notice: you can have only one jupyter job running on Sunbird.
    If an old jupyter job of yours is still running, 
    you will not be able to start a new one. 
    Use `scancel` to kill the old one.
    Alternatively, you can run the tool
    ```
    kill_remote_sunpyter_jobs.sh your-scw-username 
    ```
    from your own computer, 
    which will find all the remote jobs
    launched by sunpyter
    and terminates them.
  * **I get ERROR: /cdt_storage/<my_username> does not exist.**
    You need to log into the CDT storage log in node 
    to have your home directory created first.
  * **I get some other ERROR message and I am on Windows.**
    Chances are that some scripts were modified 
    when git downloaded them.
    Try
    ```
    dos2unix remote_script.sh
    ```
    and try again running sunpyter.  
  * **I get a "connection timed out" error**
    Your IP might have been banned.
    If you have mistyped your password 3 times
    in a row, you may have been banned for 6 hours.
    If you have time, just wait. 
    If you are in a hurry, 
    you might ask us 
    to manually unban your IP address.
    You can get your IP address 
    on `whatismyip.com`, 
    it's written right of 
    `My Public IPv4 is:`
  * **Any other problem**
    Contact us!

# Notes
Some more notes on the inner workings of sunpyter
can be found [in this guide](internals_documentation.md).

Tested on:
- Arch linux,
  - Bash 5.0.18, 
  - openSSH8.4p1, OpenSSL1.1.1h, 22 Sep 2020
- Mac OS X 10.14
  - Bash 3.2.57
  - OpenSSH_7.9p1, LibreSSL 2.7.3
- Git Bash (*auto-open not working*)
  - Bash 4.4.23, 
  - openSSH8.4p1, OpenSSL1.1.1h, 22 Sep 2020
- Microsoft Windows Subsystem for Linux (*auto-open not working*)
  - (`uname -a`): Linux 4.4.0-19041-Microsoft #488-Microsoft Mon Sep 01 13:43:00 PST 2020 x86_64 x86_64 x86_64 GNU/Linux
  - OpenSSH_7.2p2 Ubuntu-4ubuntu2.10, OpenSSL 1.0.2g  1 Mar 2016
  - GNU bash, version 4.3.48(1)-release (x86_64-pc-linux-gnu)
