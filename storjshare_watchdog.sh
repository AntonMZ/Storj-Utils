#
# Script By Anton Zheltyshev
# Version 1.0.4
# Contacts info@maxrival.com
#
# Github Storj Project - https://github.com/Storj/storjshare-daemon
# Github Storj-Utils - https://github.com/AntonMZ/Storj-Utils
#

#!/bin/bash

STATUS=$(storjshare status | grep stopped | awk -F ' ' {'print $2'})
#echo $STATUS

if [ "$OSTYPE" == "linux-gnu" ]; then
        IP=$(hostname -I)
        SESSIONS=$(netstat -np | grep node | grep tcp | wc -l)
        WATCHDOG_LOG='/var/log/storjshare-daemon-status.log'
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        IP=`ifconfig | grep "inet " | grep -v "inet6"  | grep -v "127.0.0.1" | awk '{print $2}' | tr '\n' ' '`
        SS_PID=$(ps -aux | grep farmer.js | grep -v grep | awk '{print $2}')
        SESSIONS=$(sockstat -c | grep -v "stream" | grep " $SS_PID " | wc -l | awk '{print $1}')
else
        IP="n/a for $OSTYPE"
        SESSIONS="n/a for $OSTYPE"
fi

DATE=$(date +%x:%H:%M:%S:%z)

#
# Bot API key Telegram
API_KEY=""

#
# Your id in Telegram
CHAT_ID=""

if [ -n "$STATUS" ];
then
    for line in $STATUS
    do
        curl https://api.telegram.org/bot$API_KEY/sendMessage\?chat_id\=$CHAT_ID\&text\=Node%20$line%20restarted%20on%20server%20$IP > /dev/null 2>&1
        echo "["$DATE"] node" $line "RESTARTED"  >> /var/log/storjshare-daemon-status.log
        storjshare restart --nodeid $line
    done
fi

# -----------------------------------------------------------------------------------------
# Example
# -----------------------------------------------------------------------------------------
# Telegram
# Node e3863f08061243b5a7bd07899bxxx56b79a4b6bde5 restarted on server 195.209.xx.xx
# -----------------------------------------------------------------------------------------
# Log file
# [06/08/2017:17:22:02:+0300] node e3863f08061243b5a7bd07899bxxx56b79a4b6bde5 RESTARTED
# -----------------------------------------------------------------------------------------
