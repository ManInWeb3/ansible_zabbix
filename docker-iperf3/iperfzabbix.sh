#!/bin/bash
#
# Script for automated testing of internet connection bandwidth and
# registering of the results with the Zabbix server
#
# Copyright 2014, Janis Eisaks, Riga, LV
# All rights reserved.
#
#   Permission to use, copy, modify, and distribute this software for
#   any purpose with or without fee is hereby granted, provided that
#   the above copyright notice and this permission notice appear in all
#   copies.
#
#   THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
#   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
#   USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
#   OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#   SUCH DAMAGE.
#
# Requirements: iperf3 (https://github.com/esnet/iperf)
#
# ATTENTION!!!
#
# THE HIGH LOAD OF THE INTERNET CONNECTION OVER 10 SECONDS PER MEASUREMENT
# (IF NOT MODIFIED) FOR BOTH iperf3 CLIENT AND SEVER HAS TO BE TAKEN INTO
# ACOOUNT!
# DO NOT SCHEDULE THE SCRIPT FOR EXECUTION TOO OFTEN AND/OR DURING BUSY HOURS!!!
#
# DO CONSIDER PLACEMENT OF iperf3 SERVER ON SEPARATE COMPUTER FROM ZABBIX
# SERVER AS IT MAY SIGNIFICANTLY INFLUENCE THE PERFORMANCE OF THE LATTER.
#
# In order to acquire UDP traffic bandwith parameters or for the use of
# input parameters differing from iperf3's defaults, script has to be modified
# accordingly.

#iperf3 server
IPERFS="172.28.29.72"
#Zabbix server
ZSERV="172.27.41.119"

set -o pipefail

DLOAD=`/usr/bin/iperf3 -f m -c $IPERFS -R | grep sender | awk -F " " '{print $7}'`
#in case of iperf3 failure set measurement result to 0
if [ "$?" -ne "0" ]; then
    DLOAD=0
fi

ULOAD=`/usr/bin/iperf3 -f m -c $IPERFS |grep sender|awk -F " " '{print $7}'`
if [ "$?" -ne "0" ]; then
    ULOAD=0
fi
#echo "iperf3 server:"$IPERFS", Upload=" $ULOAD "Download=" $DLOAD

#THOST=`cat /etc/zabbix/zabbix_agentd.conf|grep ^Hostname= |awk -F "=" '{print $2}'`

#send the measurement results to items of Zabbix_trapper type.
THOST="office-aucnz"
if [ -n "$THOST" ]; then
    /usr/bin/zabbix_sender -z $ZSERV -p 10051 -s $THOST -k net.bandwidth.down -vv -o $DLOAD
    /usr/bin/zabbix_sender -z $ZSERV -p 10051 -s $THOST -k net.bandwidth.up -vv -o $ULOAD
  else
    echo "Zabbix client Hostname not set in zabbix_agentd.conf!"
fi

