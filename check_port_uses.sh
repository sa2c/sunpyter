# library of bash functions 
# that can be used 
# to check that a given port is not used

check_port_ss(){
    export local PORT=$1
    which ss &> /dev/null && ss -Htan | awk '{print $4}' | cut -d':' -f2 | grep $PORT | wc -l
}

check_port_lsof(){
    export local PORT=$1
    which lsof &> /dev/null && lsof -i :$PORT| wc -l
}

check_port_netstat(){
    export local PORT=$1
    which netstat &> /dev/null && (
    netstat -an -p TCP | awk '{print $2}' | cut -d':' -f2 | grep $PORT 
    netstat -an -p UDP | awk '{print $2}' | cut -d':' -f2 | grep $PORT 
    ) | wc -l
}

check_port_uses(){

    local PORT=$1
    check_port_lsof $PORT || check_port_ss $PORT|| check_port_netstat $PORT
}

