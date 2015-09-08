#!/bin/bash
orig_gw=$(/sbin/ip route | awk '/default/ { print $3 }')
new_gw=$(route -n|grep eth1|awk '{ print $1 }'|cut -c1-9).253

route -n
route add default gw ${new_gw} eth1
route del default gw ${orig_gw}
route -n

cat >> /etc/network/interfaces << EOF
	gateway ${new_gw}
	dns-search ematters.com.tw konwen.com
	dns-nameservers 192.168.0.11 8.8.8.8 8.8.4.4
EOF
