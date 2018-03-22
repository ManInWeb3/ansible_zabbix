#!/bin/bash

#. config
#Начало месяца
fmday=`date +'%Y-%m-00 '`
#Дата без дня
fmdaym=`date +'%Y-%m '`
#Сегодня
fmdayd=`date +'%Y-%m-%d '`


#DBLIST=`echo "SHOW DATABASES LIKE 'scrmbase'"|mysql -uroot -pafn158Ug -N`
DBLIST=$(echo "SHOW DATABASES"|mysql -uroot -pafn158Ug -N)

if [ $(echo "$DBLIST"|grep "^scrmbase$"|wc -l) -eq 1 ]; then
    DBNAME="scrmbase";
    DBPWRD="zaq1xsw2";
elif [ $(echo "$DBLIST"|grep "^crmbase$"|wc -l) -eq 1 ]; then
    DBNAME="crmbase";
    DBPWRD="zaq1xsw2";
else
 echo "DB_SCRMBASE_OR_CRMBASE_NOT_FOUND"; 
 exit 1;
fi

case $1 in
astusers) users=`echo "SELECT avg FROM 00_tel_aggregate WHERE date = '$fmdaym'"|mysql -u$DBNAME -p$DBPWRD -N $DBNAME`
if [ -z $users ]; then 
    echo 0;
else
    echo $users; 
fi;;
crmusers) users=`echo "SELECT avg FROM 00_crm_aggregate WHERE date = '$fmdaym'"|mysql -u$DBNAME -p$DBPWRD -N $DBNAME`
if [ -z $users ]; then 
    echo 0;
else
    echo $users; 
fi;;
astusersd) users=`echo "SELECT qty FROM 00_tel_by_month WHERE date = '$fmdayd'"|mysql -u$DBNAME -p$DBPWRD -N $DBNAME`
if [ -z $users ]; then 
    echo 0;
else
    echo $users; 
fi;;
crmusersd) users=`echo "SELECT qty FROM 00_crm_by_month WHERE date = '$fmdayd'"|mysql -u$DBNAME -p$DBPWRD -N $DBNAME`
if [ -z $users ]; then 
    echo 0;
else
    echo $users; 
fi;;
*) echo "ERROR_WRONG_PARAM"; exit 1;;
esac

exit


