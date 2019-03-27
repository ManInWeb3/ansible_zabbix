#!/bin/bash

if [ `ls /etc/openvpn/*.conf|wc -l` -gt 0 ]; then 
    cat /etc/openvpn/*.conf|grep remote|grep -v "#"|awk '{print($2)}'>/tmp/officewan.txt
else
    echo "ВПН тунель до офиса клиента, не настроен";>/tmp/officewan.txt
fi;



