#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

. /etc/environment
. /var/mongo/hosts.sh

# @params container volume
function recreateContainer {
  serv=$(howManyServers)
  keyfile="mongo-keyfile"
  port="$DB_PORT:$DB_PORT"
  p=$DB_PORT

  echo '·· recreating container >>>> '$1' ··'

  #create container with sercurity and replica configuration
  docker run --restart=unless-stopped --name $1 --hostname $1 \
  -v mongo_storage:/data \
  $serv \
  -p $port \
  -d mongo --smallfiles \
  --keyFile /data/keyfile/$keyfile \
  --replSet $DB_REPLSET_NAME \
  --storageEngine wiredTiger \
  --port $p \
  --bind_ip 0.0.0.0

  # verify if container is ready
  wait_for_databases

  echo '·······························'
  echo '·  CONTAINER '$1' CREATED ··'
  echo '·······························'
}

function wait_for {
  echo ">>>>>>>>>>> waiting for mongodb"
  start_ts=$(date +%s)
  while :
  do
    (echo > /dev/tcp/$1/$2) >/dev/null 2>&1
    result=$?
    if [[ $result -eq 0 ]]; then
        end_ts=$(date +%s)
        echo "<<<<< $1:$2 is available after $((end_ts - start_ts)) seconds"
        sleep 3
        break
    fi
    sleep 5
  done
}

function wait_for_databases {
  ip=`ip -f inet addr show eth0 | grep -Po 'inet \K[\d.]+'`
  # make tcp call
  echo "IP == $ip PORT == 27017"
  wait_for "$ip" 27017
}

recreateContainer $DB_HOST
