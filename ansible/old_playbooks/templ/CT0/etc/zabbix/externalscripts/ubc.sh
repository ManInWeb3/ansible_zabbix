#!/bin/bash

cat /proc/user_beancounters |awk 'BEGIN{failcnt=0}{if(index($0,":")>0){failcnt=failcnt+$7;}else{failcnt=failcnt+$6;}}END{print(failcnt)}'>/tmp/beancounter



