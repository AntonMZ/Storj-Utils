#!/usr/bin/env bash
#
#
# Script By Anton Zheltyshev
# Contacts info@maxrival.com
#
# Github Storj Project - https://github.com/Storj/storjshare-daemon
# Github Storj-Utils - https://github.com/AntonMZ/Storj-Utils
#
#
# Prechecks
#------------------------------------------------------------------------------
#
# Import Node & Storjshare PATH (import from default nvm env)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

#SHELL=$(echo $SHELL | grep bash)
#if [ -z $SHELL ];
#then
#  echo 'Please use only bash'
#  exit 0
#fi

# check if jq is installed
if ! hash jq 2>/dev/null; then
  echo "Please install jq first, more info about jq @ https://stedolan.github.io/jq/"
  exit 0
fi

# check if bc is installed
if ! hash bc 2>/dev/null; then
  echo "Please install bc"
  exit 0
fi

# check if curl is installed
if ! hash curl 2>/dev/null; then
  echo "Please install curl"
  exit 0
fi

# check nvm env & storjshare
if ! hash storjshare 2>/dev/null; then
  echo "Please install storjshare or enable nvm env"
  exit 0
fi

#check netstat for linux-gnu
if [ "$OSTYPE" == "linux-gnu" ]; then
  if ! hash netstat 2>/dev/null; then
    echo "Please install net-tools packet"
    exit 0
  fi
fi

# Variables
#------------------------------------------------------------------------------
CURRENT_FOLDER=$(dirname "$0")
LOGS_FOLDER=$(cat "$CURRENT_FOLDER"/config.cfg | grep ^LOGS_FOLDER= | sed 's/^LOGS_FOLDER=//')
CONFIGS_FOLDER=$(cat "$CURRENT_FOLDER"/config.cfg | grep ^CONFIGS_FOLDER= | sed 's/^CONFIGS_FOLDER=//')
WATCHDOG_LOG=$(cat "$CURRENT_FOLDER"/config.cfg | grep ^WATCHDOG_LOG= | sed 's/^WATCHDOG_LOG=//')
EMAIL=$(cat "$CURRENT_FOLDER"/config.cfg | grep ^EMAIL= | sed 's/^EMAIL=//')
VER='b1.1.1'
HOSTNAME=$(hostname)
YEAR=$(date +%Y)
MONTH=$(date +%-m)
DAY=$(date +%-d)
DATE=$(date)
LOCALTIME=$(date +%s)
WATCHDOG_LOG_DATE=$(date +%x)
STORJ=$(storjshare -V)
RTMAX='1000'
DATA_TMP=$(storjshare status --json)
lenght=$(echo "$DATA_TMP" | jq '.|length')
MODE=$1
#------------------------------------------------------------------------------

if [ "$MODE" != "--cli" ] || [ "$MODE" != "--api" ]; then
  MODE="--cli"
#  help
#  exit 0
fi

function help()
{
    echo -e " \n" \
    "Version $VER\n" \
    "\n" \
    "Github Storj Project - https://github.com/Storj/storjshare-daemon\n"\
    "Github Storj-Utils - https://github.com/AntonMZ/Storj-Utils\n"\
    " \n" \
    "Usage: healt.sh [options]\n" \
    " \n" \
    "Options:\n" \
    "--cli - enable cli mode (ex: sh health.sh --cli)\n" \
    "--api - enable api mode (ex: sh health.sh --api)\n" \
    ""
}
#------------------------------------------------------------------------------
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  IP=$(hostname -I)
	SESSIONS=$(netstat -np | grep node | grep -c tcp)
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  IP=$(ifconfig | grep "inet " | grep -v "inet6"  | grep -v "127.0.0.1" | awk '{print $2}' | tr '\n' ' ')
	SS_PID=$(pgrep -f "farmer")
	SESSIONS=$(sockstat -c | grep -v "stream" | grep -c " $SS_PID " | awk '{print $1}')
else
	IP="n/a for $OSTYPE"
	SESSIONS="n/a for $OSTYPE"
fi

if [ "$MODE" == --cli ];then
{
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}
fi

if [ "$MODE" == --cli ];then
{
  echo -e "   _____  _                _    _____       _  _           "
  echo -e "  |   __|| |_  ___  ___   |_|  |     | ___ | ||_| ___  ___ "
  echo -e "  |__   ||  _|| . ||  _|  | |  |  |  ||   || || ||   || -_|"
  echo -e "  |_____||_|  |___||_|   _| |  |_____||_|_||_||_||_|_||___|"
  echo -e "                        |___|                              "

  echo -e " **********************************************************"
  echo -e " Version script:^ \e[0;32m $VER \e[0m \n" \
  "Hostname:^ \e[0;32m $HOSTNAME \e[0m \n" \
  "Ip:^ \e[0;32m $IP \e[0m \n" \
  "Date:^ \e[0;32m $DATE \e[0m \n" \
  "Open Sessions:^ \e[0;32m $SESSIONS \e[0m \n" \
  "Storjshare Version:^ \e[0;32m $STORJ \e[0m" | column -t -s '^'
}
fi

if [ -n "$DATA_TMP" ]; then
  if [ "$MODE" == --cli ];then
    {
      printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    }
  fi

for (( i=0; i< "$lenght"; i++ ))
do
    ID=$(echo "$DATA_TMP" | jq -r ".[$i].id")
    STATUS=$(echo "$DATA_TMP" | jq -r ".[$i].status")
    RESTARTS=$(echo "$DATA_TMP" | jq -r ".[$i].restarts")
    UPTIME=$(echo "$DATA_TMP" | jq -r ".[$i].uptime")
    PEERS=$(echo "$DATA_TMP" | jq -r ".[$i].peers")
    OFFERS=$(echo "$DATA_TMP" | jq -r ".[$i].offers")
    DRC=$(echo "$DATA_TMP" | jq -r ".[$i].dataReceivedCount")
    DELTA=$(echo "$DATA_TMP" | jq -r ".[$i].delta" | tr -d 'ms')
    PORT=$(echo "$DATA_TMP" | jq -r ".[$i].port")
    SHARE_USED_TMP=$(echo "$DATA_TMP" | jq -r ".[$i].shared")
    SHARED_PERCENT=$(echo "$DATA_TMP" | jq -r ".[$i].sharedPercent")
    BRIDGE_STATUS=$(echo "$DATA_TMP" | jq -r ".[$i].bridgeConnectionStatus")

    for line in $ID
    do
    	CURL=$(curl -s https://api.storj.io/contacts/"$line")
    	ADDRESS=$(echo "$CURL" | jq -r '.address')
      if [ "$ADDRESS" == null ];then
        if [ "$MODE" == --api ]; then
          ADDRESS="no data"
        else
          ADDRESS=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      if [ "$STATUS" == running ]; then
        if [ "$MODE" == --api ]; then
          STATUS=1
        else
          STATUS=$(echo -e "\e[0;32mNode running\e[0m")
        fi
        else
          if [ "$MODE" == --api ]; then
            STATUS=0
          else
            STATUS=$(echo -e "\e[0;31mNode stopped\e[0m")
          fi
      fi

      if [ "$BRIDGE_STATUS" == connected ]; then
        if [ "$MODE" == --api ]; then
          BRIDGE_STATUS=3
        else
          BRIDGE_STATUS=$(echo -e "\e[0;32mBridge connected\e[0m")
        fi
      elif [ "$BRIDGE_STATUS" == confirming ]; then
        if [ "$MODE" == --api ]; then
          BRIDGE_STATUS=2
        else
          BRIDGE_STATUS=$(echo -e "\e[0;33mBridge confirming\e[0m")
        fi
      elif [ "$BRIDGE_STATUS" == connecting ]; then
        if [ "$MODE" == --api ]; then
          BRIDGE_STATUS=1
        else
          BRIDGE_STATUS=$(echo -e "\e[0;33mBridge connecting\e[0m")
        fi
      else [ "$BRIDGE_STATUS" == disconnected ];
        if [ "$MODE" == --api ]; then
          BRIDGE_STATUS=0
        else
          BRIDGE_STATUS=$(echo -e "\e[0;31mBridge disconnected\e[0m")
        fi
      fi

      LS=$(echo "$CURL" | jq -r '.lastSeen')
      if [ "$LS" == null ];then
        if [ "$MODE" == --api ]; then
          LS="no data"
        else
          LS=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      RT=$(echo "$CURL" | jq '.responseTime' | awk -F '.' '{print $1}')
      if [ "$RT" == null ];then
        if [ "$MODE" == --api ]; then
          RT="0"
        else
          RT="err"
        fi
      fi

      reputation=$(echo "$CURL" | jq -r '.reputation')
      if [ "$reputation" == null ];then
        if [ "$MODE" == --api ]; then
          reputation="0"
        else
          reputation=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      AGENT=$(echo "$CURL" | jq -r '.userAgent')
      if [ "$AGENT" == null ];then
        if [ "$MODE" == --api ]; then
          AGENT="no data"
        else
          AGENT=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      PORT=$(echo "$CURL" | jq -r '.port')
      if [ "$PORT" == null ];then
        if [ "$MODE" == --api ]; then
          PORT="no data"
        else
          PORT=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      PROTOCOL=$(echo "$CURL" | jq -r '.protocol')
      if [ "$PROTOCOL" == null ];then
        if [ "$MODE" == --api ]; then
          PROTOCOL="no data"
        else
          PROTOCOL=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      LT=$(echo "$CURL" | jq -r '.lastTimeout')
      if [ "$LT" == null ];then
        if [ "$MODE" == --api ]; then
          LT="no data"
        else
          LT=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      LASTCONTRACTSENT=$(echo "$CURL" | jq -r '.lastContractSent')
      if [ "$LASTCONTRACTSENT" == null ];then
        if [ "$MODE" == --api ]; then
          LASTCONTRACTSENT="no data"
        else
          LASTCONTRACTSENT=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      SPACEAVAILABLE=$(echo "$CURL" | jq -r '.spaceAvailable')
      if [ "$SPACEAVAILABLE" == null ];then
        if [ "$MODE" == --api ]; then
          SPACEAVAILABLE="no data"
        else
          SPACEAVAILABLE=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      TR=$(echo "$CURL" | jq -r '.timeoutRate')
      if [ "$TR" == null ];then
        if [ "$MODE" == --api ]; then
          TR="-"
          TR_STATUS="no data"
        else
          TR="-"
          TR_STATUS=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      else
        if [ "$TR" == 0 ];then
          TR_STATUS=$(echo -e "\e[0;32mGood\e[0m")
        else
          TR_STATUS=$(echo -e "\e[0;31mBad - Is not null \e[0m")
        fi
      fi

    	PORT_STATUS=$(curl --silent -k "https://storjstat.com:3000/portstatus?hostname=$ADDRESS&port=$PORT" | jq -r '.status')
    	LOG_FILE="$LOGS_FOLDER"/"$line""_""$YEAR-$MONTH-$DAY".log

      # Watchdog restart couns
      if [ ! -f $WATCHDOG_LOG ]; then
        if [ "$MODE" == --cli ]; then
      	  RESTART_NODE_COUNT=$(echo -e "\e[0;32mNo log file\e[0m")
        else
          RESTART_NODE_COUNT="no file"
        fi
      else
      	RESTART_NODE_COUNT=$(grep "$WATCHDOG_LOG_DATE" "$WATCHDOG_LOG" | grep 'RESTARTED' | grep -c "$line")
      	if [ "$RESTART_NODE_COUNT" = 0 ]; then
      		RESTART_NODE_COUNT=$(echo -e "\e[0;32m0\e[0m")
      	else
      		RESTART_NODE_COUNT=$(echo -e "\e[0;31m$RESTART_NODE_COUNT\e[0m")
      	fi
      fi

      #--------------------------------------------------------------------------------------------
      # Share allocated
      SHARE_ALLOCATED_TMP=$(cat < "$CONFIGS_FOLDER"/"$line".json | grep storageAllocation | tr -d ' storageAllocation":,')
      if [ -z "$SHARE_ALLOCATED_TMP" ]; then
        if [ "$MODE" == --cli ]; then
          SHARE_ALLOCATED=$(echo '0')
        else
          SHARE_ALLOCATED=$(echo 'no data')
        fi
      else
        if [ "$MODE" == --cli ]; then
          SHARE_ALLOCATED=$SHARE_ALLOCATED_TMP
        else
          B=$(echo "$SHARE_ALLOCATED_TMP" | grep B)
          KB=$(echo "$SHARE_ALLOCATED_TMP" | grep KB)
          MB=$(echo "$SHARE_ALLOCATED_TMP" | grep MB)
          GB=$(echo "$SHARE_ALLOCATED_TMP" | grep GB)
          TB=$(echo "$SHARE_ALLOCATED_TMP" | grep TB)

          if [ -n "$KB" ];then
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED_TMP" | tr -d 'KB')
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED"*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$MB" ];then
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED_TMP" | tr -d 'MB')
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED"*1000*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$GB" ];then
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED_TMP" | tr -d 'GB')
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED"*1000*1000*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$TB" ];then
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED_TMP" | tr -d 'TB')
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED"*1000*1000*1000*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$B" ];then
            SHARE_ALLOCATED=$(echo "$SHARE_ALLOCATED_TMP" | tr -d 'B')
          else
            SHARE_USED=$(echo '-')
          fi
        fi
      fi

      #
      #--------------------------------------------------------------------------------------------
      # Share_used &  Find KB,MB,GB
      if [ -z "$SHARE_USED_TMP" ]; then
        if [ "$MODE" == --cli ]; then
          SHARE_USED=$(echo '0')
        else
          SHARE_USED=$(echo 'no data')
        fi
      else
        if [ "$MODE" == --cli ]; then
          SHARE_USED=$SHARE_USED_TMP
        else
          B=$(echo "$SHARE_USED_TMP" | grep B)
          KB=$(echo "$SHARE_USED_TMP" | grep KB)
          MB=$(echo "$SHARE_USED_TMP" | grep MB)
          GB=$(echo "$SHARE_USED_TMP" | grep GB)
          TB=$(echo "$SHARE_USED_TMP" | grep TB)

          if [ -n "$KB" ];then
            SHARE_USED=$(echo "$SHARE_USED_TMP" | tr -d 'KB' )
            SHARE_USED=$(echo "$SHARE_USED"*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$MB" ];then
            SHARE_USED=$(echo "$SHARE_USED_TMP" | tr -d 'MB' )
            SHARE_USED=$(echo "$SHARE_USED"*1000*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$GB" ];then
            SHARE_USED=$(echo "$SHARE_USED_TMP" | tr -d 'GB' )
            SHARE_USED=$(echo "$SHARE_USED"*1000*1000*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$TB" ];then
            SHARE_USED=$(echo "$SHARE_USED_TMP" | tr -d 'TB' )
            SHARE_USED=$(echo "$SHARE_USED"*1000*1000*1000*1000 | bc | awk -F '.' '{print $1}')
          elif [ -n "$B" ];then
            SHARE_USED=$(echo "$SHARE_USED_TMP" | tr -d 'B')
          else
            SHARE_USED=$(echo '0')
          fi
        fi
      fi
      #--------------------------------------------------------------------------------------------
      # Last publish
      LAST_PUBLISH=$(grep -R 'PUBLISH' "$LOG_FILE" | tail -1 | awk -F ',' '{print $NF}' | cut -b 14-37)

      if [ -z "$LAST_PUBLISH" ]; then
      	LAST_PUBLISH=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Publish counts
      PUBLISH_COUNT=$(grep -cR 'PUBLISH' "$LOG_FILE")
      if [ -z "$PUBLISH_COUNT" ]; then
      	PUBLISH_COUNT=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Last offer
      LAST_OFFER=$(grep -R 'OFFER' "$LOG_FILE" | tail -1 | awk -F ',' '{print $NF}' | cut -b 14-37)

      if [ -z "$LAST_OFFER" ]; then
      	LAST_OFFER=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Last consigned
      LAST_CONSIGNMENT=$(grep -R 'consignment' "$LOG_FILE" | tail -1 | awk -F ',' '{print $NF}' | cut -b 14-37)

      if [ -z "$LAST_CONSIGNMENT" ]; then
      	LAST_CONSIGNMENT=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Consigned counts
      CONSIGNMENT_COUNT=$(grep -cR 'consignment' "$LOG_FILE")

      if [ -z "$CONSIGNMENT_COUNT" ]; then
      	CONSIGNMENT_COUNT=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Last download
      #
      LAST_DOWNLOAD=$(grep -R 'download' "$LOG_FILE" | tail -1 | awk -F ',' '{print $NF}' | cut -b 14-37)
      if [ -z "$LAST_DOWNLOAD" ]; then
      	LAST_DOWNLOAD=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Download counts
      DOWNLOAD_COUNT=$(grep -cR 'download' "$LOG_FILE")
      if [ -z "$DOWNLOAD_COUNT" ]; then
      	DOWNLOAD_COUNT=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Last upload
      LAST_UPLOAD=$(grep -R 'upload' "$LOG_FILE" | tail -1 | awk -F ',' '{print $NF}' | cut -b 14-37)

      if [ -z "$LAST_UPLOAD" ]; then
      	LAST_UPLOAD=$(echo '-')
      fi

      #--------------------------------------------------------------------------------------------
      # Upload counts
      UPLOAD_COUNT=$(grep -cR 'upload' "$LOG_FILE")

      if [ -z "$UPLOAD_COUNT" ]; then
      	UPLOAD_COUNT=$(echo '-')
      fi

      if [ "$PORT_STATUS" == 'open' ]; then
          PORT_STATUS=$(echo -e "\e[0;32mopen\e[0m")
      elif [ "$PORT_STATUS" == 'closed' ]; then
          PORT_STATUS=$(echo -e "\e[0;31mclosed\e[0m")
      fi

      if [ "$DELTA" == '>9999' ];then
        DELTA=9999
        DELTASTATUS=$(echo -e "/ \e[0;31mBad - Your clock is not synced with a time server\e[0m")
      elif [ "$DELTA" == '...' ];then
        DELTA="..."
        DELTASTATUS=$(echo -e /"\e[0;33m No data\e[0m")
      elif [ "$DELTA" -ge 500 ] || [ "$DELTA" -le -500 ]; then
        DELTASTATUS=$(echo -e "/ \e[0;31mBad - Your clock is not synced with a time server\e[0m")
      elif [ "$DELTA" -ge 50 ] || [ "$DELTA" -le -50 ]; then
        DELTASTATUS=$(echo -e "/ \e[0;33mMedium - Your clock is not synced with a time server\e[0m")
      else
        DELTASTATUS=$(echo -e "/ \e[0;32mGood - Your clock is synced with a time server \e[0m")
      fi

      if [ "$MODE" == --cli ];then
        if [ "$RT" != err ];then
          if [ "$RT" -ge "$RTMAX" ]; then
            RT=$(echo -e "$RT / \e[0;31mBad\e[0m")
          else
            RT=$(echo -e "$RT / \e[0;32mGood\e[0m")
          fi
        else
          RT=$(echo -e "\e[0;31mAPI Server does not contain a parameter\e[0m")
        fi
      fi

      if [ "$MODE" == --cli ];then
      {
      echo -e " NodeID:^ $line \n" \
      	"Status:^ $STATUS \n" \
        "Bridge status:^ $BRIDGE_STATUS \n" \
        "Reputation:^ $reputation \n" \
        "Restarts Count:^ $RESTARTS \n" \
      	"Log_file:^ $LOG_FILE \n" \
      	"ResponseTime:^ $RT \n" \
      	"Address:^ $ADDRESS \n" \
      	"User Agent:^ $AGENT \n" \
      	"Last Seen:^ $LS \n" \
      	"Port:^ $PORT / $PORT_STATUS \n" \
      	"Protocol:^ $PROTOCOL \n" \
        "Uptime:^ $UPTIME \n" \
        "Last Timeout:^ $LT \n" \
      	"Timeout Rate:^ $TR / $TR_STATUS \n" \
      	"DeltaTime:^ $DELTA $DELTASTATUS \n" \
      	"Share_allocated:^ $SHARE_ALLOCATED \n" \
      	"Share_Used:^ $SHARE_USED \n" \
        "Share_Percent:^ $SHARED_PERCENT \n" \
      	"Last publish:^ $LAST_PUBLISH \n" \
      	"Last offer:^ $LAST_OFFER \n" \
      	"Last consigned:^ $LAST_CONSIGNMENT \n" \
      	"Last download:^ $LAST_DOWNLOAD \n" \
      	"Last upload:^ $LAST_UPLOAD \n" \
      	"Offers:^ $OFFERS \n" \
        "Peers:^ $PEERS \n" \
        "DataReceivedCount^ $DRC \n" \
      	"Publish counts:^ $PUBLISH_COUNT \n" \
      	"Download counts:^ $DOWNLOAD_COUNT \n" \
      	"Upload counts:^ $UPLOAD_COUNT \n" \
        "Last contract sent:^ $LASTCONTRACTSENT \n" \
        "Space Available:^ $SPACEAVAILABLE \n" \
      	"Consignment counts:^ $CONSIGNMENT_COUNT \n" | column -t -s '^'
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
      }
      fi

      if [ "$MODE" == --api ];then
        curl -s -k -X POST \
        -F "email=$EMAIL" \
        -F "node_id=$line" \
        -F "address=$ADDRESS" \
        -F "uptime=$UPTIME" \
        -F "localtime=$LOCALTIME" \
        -F "agent=$AGENT" \
        -F "port=$PORT" \
        -F "rt=$RT" \
        -F "share_allocated=$SHARE_ALLOCATED" \
        -F "ls=$LS" \
        -F "protocol=$PROTOCOL" \
        -F "lt=$LT" \
        -F "tr=$TR" \
        -F "os=1" \
        -F "delta=$DELTA" \
        -F "share_used=$SHARE_USED" \
        -F "last_publish=$LAST_PUBLISH" \
        -F "last_offer=$LAST_OFFER" \
        -F "last_consignment=$LAST_CONSIGNMENT" \
        -F "last_download=$LAST_DOWNLOAD" \
        -F "last_upload=$LAST_UPLOAD" \
        -F "offers=$OFFERS" \
        -F "publish_count=$PUBLISH_COUNT" \
        -F "download_count=$DOWNLOAD_COUNT" \
        -F "upload_count=$UPLOAD_COUNT" \
        -F "consignment_count=$CONSIGNMENT_COUNT" \
        -F "peers=$PEERS" \
        -F "status=$STATUS" \
        -F "bridge_status=$BRIDGE_STATUS" \
        -F "ver=$VER" \
        -F "shared_percent=$SHARED_PERCENT" \
        -F "drc=$DRC" \
        -F "lcs=$LASTCONTRACTSENT" \
        -F "SpaceAvailable=$SPACEAVAILABLE" \
        -F "reputation=$reputation" \
        -F "restarts=$RESTARTS" https://api.storj.maxrival.com
      fi
    done
  done
fi
