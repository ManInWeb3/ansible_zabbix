#!/bin/bash
if [ `ls /etc/openvpn/*.conf|wc -l` -gt 0 ]; then 
    cat /etc/openvpn/*.conf|grep "^remote"|awk '{printf $2","}'
else
    echo "";
fi;



