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
* type `ssh-keygen -t rsa` and press enter.
* You will get the output
  ```
  Generating public/private rsa key pair.
  Enter file in which to save the key (/path/to/your/home/directory/.ssh/id_rsa):
  ```
  If you do not have already a file called `~/.ssh/id_rsa`,
  you can just press enter here 
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

## SSH keys installation on Sunbird
After this step 
we will be able to connect to Sunbird
without typing your password.
This is extremely convenient
because Sunpyter needs to 
connect to sunbird many times on your behalf.
Without this step,
you would be asked 
to type in your password
many times in unexpected situations,
and this is something that can lead to errors.
To install the key on the remote machine 
(Sunbird in this case)
```
ssh-copy-id your-username-here@sunbird.swansea.ac.uk
``` 
If you have already done that in the past, 
you will get a message 
telling you that the keys already exist on the remote system.


## SSH key installation on GitHub
You can use the same key 
to deal with authentication on GitHub.
You may need to type in 
your github password at some point,
so keep it ready.

In order to do so,
1. In your browser, 
   go to `https://github.com/settings/ssh/new`.  
2. In your terminal,
   print to screen
   the content of `~/.ssh/id_rsa.pub`:
   ```
   cat ~/.ssh/id_rsa.pub
   ```
   Select the text that is displayed
   and copy it to your browser tab
   on the github website, 
   in the **Key** text field.
3. Click the green "**Add SSH key**" button.


