# library of bash functions 
# that can be used 
# to check that a given port is not used

check_port_ss(){
    export local PORT=$1
    which ss &> /dev/null && ss -Htan 2> /dev/null | awk '{print $4}' | cut -d':' -f2 | grep $PORT | wc -l
}

check_port_lsof(){
    export local PORT=$1
    which lsof &> /dev/null && lsof -i :$PORT 2> /dev/null | wc -l
}

check_port_netstat(){
    export local PORT=$1
    which netstat &> /dev/null && \
    netstat -an 2> /dev/null |\
    awk '{print $2}' | \
    awk 'BEGIN{FS=":"};{print $NF}' | \
    grep $PORT | wc -l
}

check_port_uses(){
    local PORT=$1
    check_port_lsof $PORT || check_port_ss $PORT || check_port_netstat $PORT
}

