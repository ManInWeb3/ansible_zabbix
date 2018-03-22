#!/bin/bash

#Sound quality

BMIN=`date --date="1 minutes ago"  +'%Y-%m-%d %H:%M:'`

maxjitter=0
mj=0
ml=0
PP=$(asterisk -x 'sip show channelstats')

echo "$PP"|tail -n+2 |head -n-2|\
    awk 'BEGIN{lm=0;jm=0;cc=0;}{cc++;
    i1=index($0,"(");i2=index($0,")");
    l1=strtonum(substr($0,i1+1,i2-i1-2));j1=strtonum(substr($0,i2+1,8));
    ss=substr($0,i2+1);i1=index(ss,"(");i2=index(ss,")");
    l2=strtonum(substr(ss,i1+1,i2-i1-2));j2=strtonum(substr(ss,i2+1));
    if (j1>50) j1=50;
    if (j2>50) j2=50;
    if (j1>j2) j2=j1;
    if (j2>jm) jm=j2;
    if (l1>50) l1=50;
    if (l2>50) l2=50;
    if (l1>l2) l2=l1;
    if (l2>lm) lm=l2;
    }
    END{print("maxlose maxjitt #calls");print(lm "     " jm "    " int(cc/2))}'
exit
