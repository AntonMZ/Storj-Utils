#
# Script By Anton Zheltyshev
# Version 1.0.2
# Contacts info@maxrival.com
#
# Github Storj Project - https://github.com/Storj/storjshare-daemon
# Github Storj-Utils - https://github.com/AntonMZ/Storj-Utils
#


#!/bin/bash

# Var
VER='1.0.2'
LOGS_FOLDER='/root/.config/storjshare/logs'
HOSTNAME=$(hostname)
DATE=$(date)

if [[ "$OSTYPE" == "linux-gnu" ]]; then
	IP=$(hostname -I)
elif [[ "$OSTYPE" == "freebsd"* ]]; then
	IP=`ifconfig | grep "inet " | grep -v "inet6"  | grep -v "127.0.0.1" | awk '{print $2}'`
fi

SESSIONS=$(netstat -np | grep node | grep tcp | wc -l)
STORJ=$(storjshare -V | tr -d '* ')
#RTURL='https://github.com/AntonMZ/Storj-Utils'
RTMAX='1000'

ERR1='Big delta time. Sync time with NTP server'
ERR2='Big time response'
ERR3='Is not null'
ERR4='Port closed'

echo
echo -e ' Version script:^ \e[0;32m'$VER'\e[0m \n' \
'Hostname:^ \e[0;32m'$HOSTNAME'\e[0m \n' \
'Ip:^ \e[0;32m'$IP'\e[0m \n' \
'Date:^ \e[0;32m'$DATE'\e[0m \n' \
'Open Sessions:^ \e[0;32m'$SESSIONS'\e[0m \n' \
'Storjshare Version:^\e[0;32m' $STORJ'\e[0m' | column -t -s '^'


DATA=$(storjshare status | grep running | awk -F ' ' {'print $2'})


if [ -n "$DATA" ];
then
    echo
    echo '-------------------------------------------------------------------------------'
    for line in $DATA
    do
	CURL=$(curl -s https://api.storj.io/contacts/$line)
	ADDRESS=$(echo $CURL | awk -F ',' {'print $3'} | tr -d '"' | tr -d '{address:')
	LS=$(echo $CURL | awk -F ',' {'print $1'} | tr -d '"' | tr -d '{lastSeen:')
	RT=$(echo $CURL | awk -F ',' {'print $6'} | awk -F ':' {'print $2'} | awk -F '.' {'print $1'})
	AGENT=$(echo $CURL | awk -F ',' {'print $4'} | awk -F ':' {'print $2'} | tr -d '"')
	PORT=$(echo $CURL | awk -F ',' {'print $2'} | tr -d '"' | tr -d 'port:')
	PROTOCOL=$(echo ' ' $CURL | awk -F ',' {'print $5'} | tr -d '"' | tr -d 'protocol:')
	LT=$(echo $CURL | awk -F ',' {'print $7'} | tr -d '"' | tr -d '{lastTimeout:')
	TR=$(echo $CURL | awk -F ',' {'print $8'} | tr -d '"' | tr -d '{timeoutRate:')
	PORT_STATUS=$(curl -s "http://storj.api.maxrival.com:8000/v1/?port=$PORT&ip=$ADDRESS")
	DELTA=$(grep -R 'delta' $LOGS_FOLDER/$line.log | tail -1 | awk -F ',' {'print $3'} | awk -F ' ' {'print $2'})

	if [ $TR == 0 ]
	then
	    TR_STATUS=$(echo -e "\e[0;32mgood\e[0m")
	else
	    TR_STATUS=$(echo -e "\e[0;31mbad /" $ERR3 "\e[0m")
	fi

	if [[ $PORT_STATUS == "open" ]]
    then
        PORT_STATUS=$(echo -e "\e[0;32mopen\e[0m")
    elif [[ $PORT_STATUS == "closed" ]]
    then
        PORT_STATUS=$(echo -e "\e[0;31mclose /" $ERR4 "\e[0m")
    elif [[ $PORT_STATUS == "filtered" ]]
    then
        PORT_STATUS=$(echo -e "\e[0;33mfiltered \e[0m")
    else
        PORT_STATUS=$(echo -e "\e[0;33mapi / Server not available \e[0m")
    fi


	if [ -z $DELTA ]
	then
	    echo -e '\e[0;35m Enable mode 3 in config file!!!\e[0m'
	    DELTASTATUS=$(echo -e "\e[0;35mdisable \e[0m")
	else
	    if [ $DELTA -ge "500" ] || [ $DELTA -le "-500" ]
	    then
		DELTASTATUS=$(echo -e "/ \e[0;31mbad / "$ERR1"\e[0m")
	    elif [ $DELTA -ge "50" ] || [ $DELTA -le '-50' ]
	    then
		DELTASTATUS=$(echo -e "/ \e[0;33mmedium \e[0m")
	    else
		DELTASTATUS=$(echo -e "/ \e[0;32mgood \e[0m")
	    fi
	fi

	if [ $RT -ge $RTMAX ]
        then
    	    RT=$(echo -e $RT "/\e[0;31m bad / "$ERR2"\e[0m")
	else
	    RT=$(echo -e $RT "/ \e[0;32mgood\e[0m")
	fi


	echo -e " NodeID:^" $line "\n" \
	"ResponseTime:^" $RT "\n" \
	"Address:^" $ADDRESS "\n" \
	"User Agent:^" $AGENT "\n" \
	"Last Seen:^" $LS "\n" \
	"Port:^" $PORT "/" $PORT_STATUS "\n" \
	"Protocol:^" $PROTOCOL "\n" \
	"Last Timeout:^" $LT "\n" \
	"Timeout Rate:^" $TR "/" $TR_STATUS "\n" \
	"DeltaTime:^" $DELTA $DELTASTATUS "\n" | column -t -s "^"

	echo "-------------------------------------------------------------------------------"
    done
fi
