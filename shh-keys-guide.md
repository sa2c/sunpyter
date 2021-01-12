# SSH keys guide

## SSH key creation
Check if you have the files `~/.ssh/id_rsa`
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

These are the expected steps:
* type `ssh-keygen -t rsa` and press `return`.
* You will get the output
  ```
  Generating public/private rsa key pair.
  Enter file in which to save the key (/path/to/your/home/directory/.ssh/id_rsa):
  ```
  If you do not have already a file called `~/.ssh/id_rsa`,
  you can just press `return` here 
  and use the default location displayed in brackets.
* You will then get
  ```
  Enter passphrase (empty for no passphrase):
  ```
  Here you need to type a passphrase 
  (not a simple password, it needs to be strong.
  You can use a full sentence, for example).
  You won't be able to see what you're typing.
* You will be prompted to type the same passphrase again:
  ```
  Enter same passphrase again:
  ```
  You won't be able to see what you're typing.
* If you haven't made any mistakes, 
  you should see something similar to
  ```
  Your identification has been saved in /path/to/your/home/directory/.ssh/id_rsa
  Your public key has been saved in /path/to/your/home/directory/.ssh/id_rsa.pub
  The key fingerprint is:
  SHA256:hKoeWtgMY/bYWkg7KcvJOWw5MJ87bzDAlZjY9swWHCs your-username@your-machine
  The key's randomart image is:
  +---[RSA 3072]----+
  |..o.o.           |
  |.oooo. .         |
  |..E+... .        |
  |.. .=. .         |
  |o= ..   S        |
  |**X.             |
  |=OBB             |
  |+@X..            |
  |+*==.            |
  +----[SHA256]-----+
  ```
  If so, then you've configured your ssh keys correctly.   

## SSH keys installation
Install the key on the remote machine.
This step is safe.
```
ssh-copy-id your-username-here@sunbird.swansea.ac.uk
``` 
If you have already done that, 
you will get a message 
telling you that the keys already exist on the remote system.
