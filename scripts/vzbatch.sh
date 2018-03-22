#!/bin/bash


vzlist|awk '{print $1}'|tail -n+2| \
while read CT; do
#    if [ $CT -gt 200 ]; then
    if [ $CT -eq 253 ]; then
	continue;
    fi
    echo $CT
    mkdir -p /vz/root/$CT/root/.ssh
    cp -f ./authorized_keys /vz/root/$CT/root/.ssh/authorized_keys
    vzctl exec $CT 'chmod 700 /root/.ssh&&chmod 600 /root/.ssh/authorized_keys' &

done
