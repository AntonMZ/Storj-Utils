#
# Script By Anton Zheltyshev
# Version 1.0.1
# Contacts info@maxrival.com
#
# Github Storj Project - https://github.com/Storj/storjshare-daemon
# Github Storj-Utils - https://github.com/AntonMZ/Storj-Utils
#


#!/bin/bash

# Var
HOSTNAME=$(hostname)
DATE=$(date)
IP=$(hostname -I)
SESSIONS=$(netstat -np | grep node | grep tcp | wc -l)
STORJ=$(storjshare -V | tr -d '* ')

echo
echo -e ' Hostname:^ \e[0;32m'$HOSTNAME'\e[0m \n' \
'Ip:^ \e[0;32m'$IP'\e[0m \n' \
'Date:^ \e[0;32m'$DATE'\e[0m \n' \
'Open Sessions:^ \e[0;32m'$SESSIONS'\e[0m \n' \
'Storjshare Version:^\e[0;32m'$STORJ'\e[0m' | column -t -s '^'


DATA=$(storjshare status | grep running | awk -F ' ' {'print $2'})


if [ -n "$DATA" ];
then
    echo
    echo -e '---------------------------------------- | -----\n Node-Id | Time \n  ---------------------------------------- | -----' | column -t

    for line in $DATA
    do
	OUT=$(curl -s https://api.storj.io/contacts/$line | awk -F ',' {'print $6'} | awk -F ':' {'print $2'} | awk -F '.' {'print $1'})
	if [ $OUT -ge '1000' ]
	    then
		echo -e $line "| \e[0;31m"$OUT "\e[0m\n" | column -t
	    else
		echo -e $line "| \e[0;32m"$OUT "\e[0m\n" | column -t
	fi
    done
    echo -e '---------------------------------------- | -----' | column -t
fi