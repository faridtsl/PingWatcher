strindex() { 
  x="${1%%$2*}"
  [[ $x = $1 ]] && echo -1 || echo ${#x}
}
 
lastTime=$(date +%s)
cnt=1
 
tcpdump -l -i eth0 icmp and icmp[icmptype]=icmp-echo -n | while read b; do
    idx=$(strindex "${b}" ">")
    idx=$[$idx + 2]
    idxf=$(strindex "${b:$idx}" ":")
    pinger=$(echo $b | grep -o -E "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1 | sed -e 's/^0\+//')
    if [ ${b:$idx:$idxf} = $(ifconfig eth0 | grep inet | awk '{print $2}' | cut -d':' -f2) ]
    then
        currTime=$(date +%s)
        testvar=$[$lastTime + 3]
        if [ "$currTime" -gt "$testvar" ]
        then
            zenity --notification --text="You've been pinged by "$pinger" ("$cnt")"
            echo "Pinged by "$pinger" "$cnt" times."
            lastTime=$(date +%s)
            if [ $cnt -gt 100 ]
            then
                echo $pinger" Blocked after pinging "$cnt" times."
                iptables -A INPUT -s $pinger -p icmp -j DROP
            fi
            cnt=1
        else
            cnt=$[$cnt + 1]
        fi
    else
        echo "pings went from "$pinger" to "${b:$idx:$idxf}
    fi
done
