#!/bin/bash
if [ `ls /etc/openvpn/*.conf|wc -l` -gt 0 ]; then 
    route -n|grep tap|awk '{printf $1","}'
else
    echo "";
fi;



