#
# Script By Anton Zheltyshev
# Version 1.0.4
# Contacts info@maxrival.com
#
# Github Storj Project - https://github.com/Storj/storjshare-daemon
# Github Storj-Utils - https://github.com/AntonMZ/Storj-Utils
#

#!/bin/bash

# Variables
#------------------------------------------------------------------------------

# check if jq is installed
if [ ! hash jq 2>/dev/null ]; then
   echo "Please install jq first, more info about jq @ https://stedolan.github.io/jq/"
   exit
fi

VER='1.0.4'
LOGS_FOLDER='/root/.config/storjshare/logs'
HOSTNAME=$(hostname)
YEAR=$(date +%Y)
MONTH=$(date +%-m)
DAY=$(date +%-d)
DATE=$(date)
WATCHDOG_LOG='/var/log/storjshare-daemon-status.log'

if [ "$OSTYPE" == "linux-gnu" ]; then
        IP=$(hostname -I)
	SESSIONS=$(netstat -np | grep node | grep tcp | wc -l)
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        IP=`ifconfig | grep "inet " | grep -v "inet6"  | grep -v "127.0.0.1" | awk '{print $2}' | tr '\n' ' '`
	SS_PID=$(ps -aux | grep farmer.js | grep -v grep | awk '{print $2}')
	SESSIONS=$(sockstat -c | grep -v "stream" | grep " $SS_PID " | wc -l | awk '{print $1}')
else
	IP="n/a for $OSTYPE"
	SESSIONS="n/a for $OSTYPE"
fi

WATCHDOG_LOG_DATE=$(date +%x)
STORJ=$(storjshare -V)
RTMAX='1000'

ERR1='Big delta time. Sync time with NTP server'
ERR2='Big time response'
ERR3='Is not null'

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

echo -e ' Version script:^ \e[0;32m'$VER'\e[0m \n' \
'Hostname:^ \e[0;32m'$HOSTNAME'\e[0m \n' \
'Ip:^ \e[0;32m'$IP'\e[0m \n' \
'Date:^ \e[0;32m'$DATE'\e[0m \n' \
'Open Sessions:^ \e[0;32m'$SESSIONS'\e[0m \n' \
'Storjshare Version:^\e[0;32m' $STORJ'\e[0m' | column -t -s '^'

DATA=$(storjshare status | grep running | awk -F ' ' {'print $2'})

if [ -n "$DATA" ]; then
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

    for line in $DATA
    do
	CURL=$(curl -s https://api.storj.io/contacts/$line)
	ADDRESS=$(echo $CURL | jq -r '.address')
	LS=$(echo $CURL | jq -r '.lastSeen')
	RT=$(echo $CURL | jq '.responseTime' | awk -F '.' {'print $1'})
	AGENT=$(echo $CURL | jq -r '.userAgent')
	PORT=$(echo $CURL | jq -r '.port')
	PROTOCOL=$(echo $CURL | jq -r '.protocol')
	LT=$(echo $CURL | jq -r '.lastTimeout')
	TR=$(echo $CURL | jq -r '.timeoutRate')
	PORT_STATUS=$(curl -s "http://storj.api.maxrival.com:8000/v1/?port=$PORT&ip=$ADDRESS")
	DELTA=$(grep -R 'delta' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | tail -1 | awk -F ',' {'print $3'} | awk -F ' ' {'print $2'})
	LOG_FILE=$(echo "$LOGS_FOLDER/$line"_"$YEAR-$MONTH-$DAY.log")

# Watchdog restart couns
if [ ! -f $WATCHDOG_LOG ]; then
	RESTART_NODE_COUNT=$(echo -e "\e[0;32mNo log file\e[0m")
else
	RESTART_NODE_COUNT=$(grep $WATCHDOG_LOG_DATE $WATCHDOG_LOG | grep 'RESTARTED' | grep $line | wc -l)

	if [ $RESTART_NODE_COUNT = 0 ]; then
		RESTART_NODE_COUNT=$(echo -e "\e[0;32m0\e[0m")
	else
		RESTART_NODE_COUNT=$(echo -e "\e[0;31m$RESTART_NODE_COUNT\e[0m")
	fi
fi

#--------------------------------------------------------------------------------------------
# Share allocated
SHARE_ALLOCATED_TMP=$(cat $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | grep storageAllocated | tail -1 | awk -F ':' {'print $6'} | awk -F ',' {'print $1'})
SHARE_ALLOCATED=$(expr $SHARE_ALLOCATED_TMP / 1048576)

#
#--------------------------------------------------------------------------------------------
# Share_used
SHARE_USED_TMP=$(cat $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | grep storageUsed | tail -1 | awk -F ':' {'print $7'} | awk -F ',' {'print $1'})
SHARE_USED=$(expr $SHARE_USED_TMP / 1048576)

#--------------------------------------------------------------------------------------------
# Last publish
LAST_PUBLISH=$(grep -R 'PUBLISH' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | tail -1 | awk -F ',' {'print $NF'} | tr -d 'timestamp":"}')

if [ -z $LAST_PUBLISH ]; then
	LAST_PUBLISH=$(echo 'None publish')
fi

#--------------------------------------------------------------------------------------------
# Publish counts
PUBLISH_COUNT=$(grep -R 'PUBLISH' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | wc -l)
if [ -z $PUBLISH_COUNT ]; then
	PUBLISH_COUNT=$(echo 0)
fi

#--------------------------------------------------------------------------------------------
# Last offer
LAST_OFFER=$(grep -R 'OFFER' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | tail -1 | awk -F ',' {'print $NF'} | tr -d 'timestamp":"}')

if [ -z $LAST_OFFER ]; then
	LAST_OFFER=$(echo 'None offers')
fi

#--------------------------------------------------------------------------------------------
# Offers counts
OFFER_COUNT=$(grep -R 'OFFER' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | wc -l)

if [ -z $OFFER_COUNT ]; then
	OFFER_COUNT=$(echo 0)
fi

#--------------------------------------------------------------------------------------------
# Last consigned
LAST_CONSIGNMENT=$(grep -R 'consignment' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | tail -1 | awk -F ',' {'print $NF'} | tr -d 'timestamp":"}')

if [ -z $LAST_CONSIGNMENT ]; then
	LAST_CONSIGNMENT=$(echo 'None consignments')
fi

#--------------------------------------------------------------------------------------------
# Consigned counts
CONSIGNMENT_COUNT=$(grep -R 'consignment' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | wc -l)

if [ -z $CONSIGNMENT_COUNT ]; then
	CONSIGNMENT_COUNT=$(echo 0)
fi

#--------------------------------------------------------------------------------------------
# Last download
#
LAST_DOWNLOAD=$(grep -R 'download' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | tail -1 | awk -F ',' {'print $NF'} | tr -d 'timestamp":"}')
if [ -z $LAST_DOWNLOAD ]; then
	LAST_DOWNLOAD=$(echo 'None downloads')
fi

#--------------------------------------------------------------------------------------------
# Download counts
DOWNLOAD_COUNT=$(grep -R 'download' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | wc -l)
if [ -z $DOWNLOAD_COUNT ]; then
	DOWNLOAD_COUNT=$(echo 0)
fi

#--------------------------------------------------------------------------------------------
# Last upload
LAST_UPLOAD=$(grep -R 'upload' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | tail -1 | awk -F ',' {'print $NF'} | tr -d 'timestamp":"}')

if [ -z $LAST_UPLOAD ]; then
	LAST_UPLOAD=$(echo 'None uploads')
fi

#--------------------------------------------------------------------------------------------
# Upload counts
UPLOAD_COUNT=$(grep -R 'upload' $LOGS_FOLDER/$line\_$YEAR-$MONTH-$DAY.log | wc -l)

if [ -z $UPLOAD_COUNT ]; then
	UPLOAD_COUNT=$(echo 0)
fi

#--------------------------------------------------------------------------------------------
if [ $TR == 0 ]; then
    TR_STATUS=$(echo -e "\e[0;32mgood\e[0m")
else
    TR_STATUS=$(echo -e "\e[0;31mbad /" $ERR3 "\e[0m")
fi


if [ $PORT_STATUS == "open" ]; then
    PORT_STATUS=$(echo -e "\e[0;32mopen\e[0m")
elif [ $PORT_STATUS == "closed" ]; then
    PORT_STATUS=$(echo -e "\e[0;31mclosed\e[0m")
elif [ $PORT_STATUS == "filtered" ]; then
    PORT_STATUS=$(echo -e "\e[0;33mfiltered\e[0m")
elif [ $PORT_STATUS == "wrong parametrs" ]; then
    PORT_STATUS=$(echo -e "\e[0;31mwrong parametrs\e[0m")
else
    PORT_STATUS=$(echo -e "\e[0;33mapi / Server not available \e[0m")
fi

if [ -z $DELTA ]; then
	DELTA=$(echo -e "\e[0;35mNone /\e[0m")
	DELTASTATUS=$(echo -e "\e[0;35mMaybe you need enable mode 3 in config file! or delta not present in log file /need restart nodes/\e[0m")
else
    if [ $DELTA -ge "500" ] || [ $DELTA -le "-500" ]; then
	DELTASTATUS=$(echo -e "/ \e[0;31mbad / Your clock is not synced with a time server\e[0m")
    elif [ $DELTA -ge "50" ] || [ $DELTA -le '-50' ]; then
	DELTASTATUS=$(echo -e "/ \e[0;33mmedium / Your clock is not synced with a time server\e[0m")
    else
	DELTASTATUS=$(echo -e "/ \e[0;32mgood / Your clock is synced with a time server \e[0m")
    fi
fi

if [ $RT -ge $RTMAX ]; then
    RT=$(echo -e $RT "/\e[0;31m bad / "$ERR2"\e[0m")
else
    RT=$(echo -e $RT "/ \e[0;32mgood\e[0m")
fi

echo -e " NodeID:^" $line "\n" \
  "Restarts Node:^" $RESTART_NODE_COUNT "\n" \
	"Log_file:^ "$LOG_FILE "\n" \
	"ResponseTime:^" $RT "\n" \
	"Address:^" $ADDRESS "\n" \
	"User Agent:^" $AGENT "\n" \
	"Last Seen:^" $LS "\n" \
	"Port:^" $PORT "/" $PORT_STATUS "\n" \
	"Protocol:^" $PROTOCOL "\n" \
	"Last Timeout:^" $LT "\n" \
	"Timeout Rate:^" $TR "/" $TR_STATUS "\n" \
	"DeltaTime:^" $DELTA $DELTASTATUS "\n" \
	"Share_allocated:^" $SHARE_ALLOCATED "MB (telemetry report)\n" \
	"Share_Used:^" $SHARE_USED "MB (telemetry report)\n" \
	"Last publish:^" $LAST_PUBLISH "\n" \
	"Last offer:^" $LAST_OFFER "\n" \
	"Last consigned:^" $LAST_CONSIGNMENT "\n" \
	"Last download:^" $LAST_DOWNLOAD "\n" \
	"Last upload:^" $LAST_UPLOAD "\n" \
	"Offers counts:^" $OFFER_COUNT "\n" \
	"Publish counts:^" $PUBLISH_COUNT "\n" \
	"Download counts:^" $DOWNLOAD_COUNT "\n" \
	"Upload counts:^" $UPLOAD_COUNT "\n" \
	"Consignment counts:^" $CONSIGNMENT_COUNT "\n" | column -t -s "^"

	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    done
fi
