#!/bin/bash
echo "Время обновления данных: "$(date)
ifconfig venet0:0|grep addr:|awk '{print $2}'|awk 'BEGIN{FS=":"}{print("IP адрес виртуального сервера: " $2)}'
wget -q -O - http://formyip.com/ | awk '/The/{print("WAN IP адрес HN сервера: " $5)}'
if [ `ls /etc/openvpn/*.conf|wc -l` -gt 0 ]; then 
    cat /etc/openvpn/*.conf|grep remote|grep -v "#"|awk '{print("WAN IP адрес офиса клиента: " $2)}'
    route -n|grep tap|awk '{print("Адрес локальной сети офиса клиента:" $1)}'
else
    echo "ВПН тунель до офиса клиента, не настроен";
fi;



