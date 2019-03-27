#!/bin/sh
# backup zabbix config only
#set -x
DBNAME=zabbix
DBUSER=zabbix
DBPASS=xxx

DBCONTAINER="$(docker ps|grep postgres|awk '{print($1)}')"   #"fb60cd42d093"


BK_DEST=/home/zabbix/zabbix-backups
mkdir -p $BK_DEST
date=`date +%Y%m%d.%s`

# zabbix schema
#eval "docker exec $DBCONTAINER bash -lc 'pg_dump -U "$DBUSER" -w --dbname "$DBNAME" --schema-only -c --if-exist' > $BK_DEST/$date-$DBNAME-schema.sql"

# zabbix config
# mysqldump -u"$DBUSER"  -p"$DBPASS" -B "$DBNAME" --single-transaction --no-create-info --no-create-db \

HISTORYTABLES="--exclude-table-data=public.acknowledges \
--exclude-table-data=public.alerts \
--exclude-table-data=public.auditlog \
--exclude-table-data=public.auditlog_details \
--exclude-table-data=public.escalations \
--exclude-table-data=public.events \
--exclude-table-data=public.history \
--exclude-table-data=public.history_log \
--exclude-table-data=public.history_str \
--exclude-table-data=public.history_str_sync \
--exclude-table-data=public.history_sync \
--exclude-table-data=public.history_text \
--exclude-table-data=public.history_uint \
--exclude-table-data=public.history_uint_sync \
--exclude-table-data=public.trends \
--exclude-table-data=public.trends_uint"

eval "docker exec $DBCONTAINER bash -lc 'pg_dump -U "$DBUSER" -w --dbname "$DBNAME" -c --if-exist "$HISTORYTABLES"' -F t > $BK_DEST/$date-$DBNAME-config.sql"
tar cjvf $BK_DEST/$date-$DBNAME-config.tar.bz $BK_DEST/$date-$DBNAME-config.sql
rm -f $BK_DEST/$date-$DBNAME-config.sql

