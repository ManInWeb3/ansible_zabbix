#!/bin/bash

#BMIN=`date --date="1 minutes ago"  +'%Y-%m-%d %H:%M:'`
sudo ls /home/asterisk/trunks/* |awk '{print("\n" $1);system(" cat " $1)}'
sudo cat /etc/asterisk/extensions.conf|grep -v "^;"|grep -v "^#"
sudo cat /etc/asterisk/sip.conf|grep "](Lo"|grep -v "^;"



                                                                                                                                                                                                                exit 0   

