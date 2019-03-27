#!/bin/bash

#if [ -z $1 ] || [ -z $2 ]; then
if [ -z $1 ]; then
    exit 1
fi

FILECACHE="/tmp/zabbix.mysql.cache"
TTLCACHE="25"
TIMENOW=`date '+%s'`
##### CACHE #####
if [ -s "${FILECACHE}" ]; then
    TIMECACHE=`stat -c"%Z" "${FILECACHE}"`
else
    TIMECACHE=0
fi

if [ "$((${TIMENOW} - ${TIMECACHE}))" -gt "${TTLCACHE}" ]; then
    echo "" >> ${FILECACHE} 
    DATACACHE=`mysqladmin -u root -pafn158Ug extended-status` || exit 1
    echo "${DATACACHE}" > ${FILECACHE} 
  fi

#HOST_HOST=$1
QUERY_KEY=$1

if [ "x$QUERY_KEY" = "xReplication_delay" ]; then

    mysql -uroot -ppassword -h127.0.0.1 -P3306 -Dheartbeat_db -e "SELECT UNIX_TIMESTAMP() - UNIX_TIMESTAMP(ts) FROM heartbeat ORDER BY id DESC LIMIT 1" | sed '1d'

else

     cat ${FILECACHE} | grep -w "$QUERY_KEY" | awk '{print $4}'

fi

