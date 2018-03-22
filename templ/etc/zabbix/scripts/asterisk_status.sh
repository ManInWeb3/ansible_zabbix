#!/bin/bash

BMIN=`date --date="1 minutes ago"  +'%Y-%m-%d %H:%M:'`

case $1 in
#active_calls) sudo /usr/sbin/asterisk -rvvvvvx 'core show channels'|grep --text -i 'active call'|awk '{print $1}';;
answrd_calls) echo "SELECT COUNT(*) FROM cdr WHERE LEFT(calldate,17) = '$BMIN' and disposition='ANSWERED'"|mysql -ucrmbase -pzaq1xsw2 crmbase|grep -v "COUNT";;
active_calls) echo "SELECT COUNT(*) FROM cdr WHERE LEFT(calldate,17) = '$BMIN'"|mysql -ucrmbase -pzaq1xsw2 crmbase|grep -v "COUNT";;
*) echo $ERROR_WRONG_PARAM; exit 1;;
esac
                                                                                                                                                                                                                exit 0   

