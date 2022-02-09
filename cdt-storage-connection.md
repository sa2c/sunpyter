# Connect to the CDT storage login node

This step is necessary 
to create your home directory
on the CDT storage,
which will be the working directory 
of the jupyter notebook.

The process is really simple:
start the connection 
to the CDT storage login node 
via SSH, 
type in your password,
and you are done.

**IMPORTANT NOTICE**: 
*if you type your password wrong 3 times
you will be banned from accessing the services
for up to 24 hours (fail2ban policy).*

Steps:
0. Read all these steps carefully before continuing.
1. Make sure you know your SuperComputing Wales 
   **password and username**.
   If you are unsure about what the password is,
   you can reset it via
   `my.supercomputing.wales`.
   1. Log into that page via your Welsh institution,
   2. select `Reset SCW password`
   3. Type in your password twice
   4. Wait a couple of minutes 
      (you should receive an email
      telling you that the password was changed)
  Your Supercomputing Wales **username**
  is also displayed in the dashboard
  (the main page)
  once you log into `my.supercomputing.wales`.
  The username usually starts with a single letter
  followed by a dot:
  - `a.` for Aberystwyth-based users,
  - `b.` for Bangor-based users,
  - `c.` for Cardiff-based users,
  - `s.` for Swansea-based users.

2. Once you are dead sure about your password and username,
   you can open a terminal and start a SSH connection.
   
   Let's assume your username is `s.michele.mesiti`,
   then you have to type
   ```bash
   ssh s.michele.mesiti@sa2c-backup2.swansea.ac.uk
   ```
   The terminal will output this text:
   ```
   s.michele.mesiti@sa2c-backup2.swansea.ac.uk's password:
   ```
   meaning it is asking for your password.
   Now yout can type it.
   **NOTICE: NOTHING WILL APPEAR ON SCREEN WHILE YOU ARE TYPING YOUR PASSWORD,
   NOT EVEN ASTERISKS.
   IF YOU THINK YOU MADE A TYPO, PRESS BACKSPACE COMPULSIVELY
   ENOUGH TIME TO DELETE WHAT YOU HAVE WRITTEN SO FAR
   AND START OVER.** 
   After typing your password, press return or enter.
3. You will have succeeded 
   if you get a prompt on the remote machine that looks like this:
   ```
  [s.michele.mesiti@sa2c-backup2 ~]$ 
   ```
   if you now type
   ```
   pwd
   ```
   you should get something along the lines of
   ```
   /cdt_storage/s.michele.mesiti
   ```
   as output.
   
   
   




