#!/bin/bash

rk=0
k=0

if [ `ls /etc/openvpn/*.conf|wc -l` -eq 0 ]; then 
    echo "Нет офисов подключенных через ВПН. Проверить связь с офисом автомаитчески не возможно.";
    exit
fi;


echo "Проверка связи до WAN интерфейсов офисов клиента:"
if [ `ls /etc/openvpn/*.conf|wc -l` -gt 0 ]; then 
    
    cat /etc/openvpn/*.conf|grep "^remote"|awk '{print($2)}'| 
    while read ip; do
	pr=`ping -c 3 $ip |grep "packets transmitted" |awk 'BEGIN{FS=","}{print($3)}'|awk '{print($1)}'`
	echo "До $ip % потернных пакетов: $pr (должен быть 0%)"
	(( k++)) 
	echo $k>/tmp/tmp1.tmp
	if [[ "$pr" == "0%" ]]; then
	    (( rk++))
	fi
	echo $rk>/tmp/tmp.tmp
#	awk -v ipp=${ip} '{print("До " ipp " % потернных пакетов: " $1 " (должен быть 0%)")}'
    done
    #    ping -c 3 $WANIP| grep "packets transmitted"
#   
else
    echo "Нет офисов подключенных через ВПН. Проверить связь с офисом автомаитчески не возможно.";
fi;
rk=`cat /tmp/tmp.tmp`
k=`cat /tmp/tmp1.tmp`

echo " ";
if [ $rk -eq $k ]; then
    echo "Внешние IP адреса доступны."
else
    echo "Офис клиентов не доступен. (ping не доходит)"
fi
echo "------------------------------------------------"

rk=0
k=0
echo " "
echo "Проверка связи через ВПН тунель:"
if [ `ls /etc/openvpn/*.conf|wc -l` -gt 0 ]; then 
    route -n|grep tap|awk '{print(substr($1,1,length($1)-1) "1")}'| \
    while read ip; do
        pr=`ping -c 3 $ip | grep "packets transmitted" |awk 'BEGIN{FS=","}{print($3)}'|awk '{print($1)}'`
	echo "До $ip % потернных пакетов: $pr (должен быть 0%)"
	(( k++))
	if [[ "$pr" == "0%" ]]; then
	    (( rk++))
	fi
	echo $rk>/tmp/tmp.tmp
	echo $k>/tmp/tmp1.tmp
    done
else
    echo "Нет офисов подключенных через ВПН. Проверить связь с офисом автомаитчески не возможно.";
fi;

rk=`cat /tmp/tmp.tmp`
k=`cat /tmp/tmp1.tmp`

echo " ";
if [ $rk -eq $k ]; then
    echo "ВПН тунели в порядке."
else
    echo "С ВПН тунелями что-то не так."
fi
