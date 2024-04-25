# library of bash functions
# to return a valid ssh key

get_keyfile(){
    if [ ! -d "${HOME}/.ssh" ]
    then
	echo "No SSH keys found. You need to set up an SSH key." >&2
	return 1
    elif [ -f "${HOME}/.ssh/id_rsa" ]
    then
	echo "${HOME}/.ssh/id_rsa"
    elif [ -f "${HOME}/.ssh/id_ecdsa" ]
    then
        echo "${HOME}/.ssh/id_ecdsa"
    elif [ -f "${HOME}/.ssh/id_ed25519" ]
    then
	echo "${HOME}/.ssh/id_ed25519"
    elif [ -f "${HOME}/.ssh/id_ecdsa_sk" ]
    then
	echo "${HOME}/.ssh/id_ecdsa_sk"
    elif [ -f "${HOME}/.ssh/id_ed25519_sk" ]
    then
	echo "${HOME}/.ssh/id_ed25519_sk"
    else
	echo "No SSH keys found. You need to set up an SSH key." >&2
	return 1
    fi
}
