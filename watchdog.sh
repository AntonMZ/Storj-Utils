#
# Script By Anton Zheltyshev
# Version 1.0.4
# Contacts info@maxrival.com
#
# Github Storj Project - https://github.com/Storj/storjshare-daemon
# Github Storj-Utils - https://github.com/AntonMZ/Storj-Utils
#

#!/bin/bash

#!/bin/bash

STATUS=$(/usr/local/bin/storjshare status | grep stopped | awk -F ' ' {'print $2'})
#echo $STATUS
IP=$(hostname -I)
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


#[06/08/2017:17:22:02:+0300] node e3863f08061243b5a7bd07899b356b79a4b6bde5 RESTARTED
