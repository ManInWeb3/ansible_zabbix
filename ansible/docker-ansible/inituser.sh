#!/bin/bash
set -exo pipefail

cmd=""
for c in "$@"; do
    cmd="$cmd $c";
done
if [ ${#cmd} -gt 0 ]; then
    cmd="${cmd:1}"
fi
if [[ -z ${DENV_USER+x} || -z ${DENV_USER_ID+x} ]]; then
    echo -e "\033[01;32mUser is not provided, use root.\nTo execute from current user add \`-e DENV_USER=\${USER} -e DENV_USER_ID=\$(id -u \${USER}) -e DENV_GROUP_ID=\$(id -g \${USER})\` to the docker run command.\033[00m"; 
else
    if ! getent passwd $DENV_USER > /dev/null
      then
        echo "Creating user $DENV_USER:$DENV_USER ($DENV_USER_ID:$DENV_GROUP_ID)"
        addgroup -g $DENV_GROUP_ID $DENV_USER
        adduser -S -u $DENV_USER_ID -g $DENV_USER -h /home -s /bin/bash -D $DENV_USER
        echo "${DENV_USER}:${DENV_USER}" | chpasswd
        getent passwd $DENV_USER
      fi
    sudo -u $DENV_USER -E -H /bin/bash -c "$cmd"
fi
