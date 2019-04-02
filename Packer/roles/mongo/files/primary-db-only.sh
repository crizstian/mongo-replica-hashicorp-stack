#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

. /etc/environment

function init_replica_set {
  docker exec -i $DB_HOST bash -c 'mongo < /data/admin/replica.js'
  sleep 2
  docker exec -i $DB_HOST bash -c 'mongo < /data/admin/admin.js'
  sleep 2
  docker exec -i $DB_HOST bash -c 'mongo -u '$DB_REPLICA_ADMIN' -p '$DB_REPLICA_ADMIN_PASS' --eval "rs.status()" --authenticationDatabase "admin"'
}

# @params server primary-mongo-container
function add_replicas {
  echo '·· adding replicas >>>> ··'

  # add nuppdb replicas
  for server in $DB2 $DB3
  do
    rs="rs.add('$server:$DB_PORT')"
    add='mongo --eval "'$rs'" -u '$DB_REPLICA_ADMIN' -p '$DB_REPLICA_ADMIN_PASS' --authenticationDatabase="admin"'
    echo ">>>>>>>>>>> waiting for mongodb server $server to be ready"
    sleep 5
    wait_for_databases $server
    docker exec -i $DB_HOST bash -c "$add"
  done
}

function check_status {
  docker exec -i $DB_HOST bash -c 'mongo -u '$DB_REPLICA_ADMIN' -p '$DB_REPLICA_ADMIN_PASS' --eval "rs.status()" --authenticationDatabase "admin"'
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
  # make tcp call
  echo "IP == $IP PORT == $DB_PORT"
  wait_for "$IP" $DB_PORT
}

function setupDefaultBookStoreData {
  docker exec -i $DB_HOST mongoimport --db bookstore --collection books --file /data/admin/books.json -u $BOOKSTORE_DBUSER -p $BOOKSTORE_DBPASS --authenticationDatabase=admin
  docker exec -i $DB_HOST mongoimport --db bookstore --collection authors --file /data/admin/authors.json -u $BOOKSTORE_DBUSER -p $BOOKSTORE_DBPASS --authenticationDatabase=admin
  docker exec -i $DB_HOST mongoimport --db bookstore --collection category --file /data/admin/category.json -u $BOOKSTORE_DBUSER -p $BOOKSTORE_DBPASS --authenticationDatabase=admin
  docker exec -i $DB_HOST mongoimport --db bookstore --collection publisher --file /data/admin/publisher.json -u $BOOKSTORE_DBUSER -p $BOOKSTORE_DBPASS --authenticationDatabase=admin
}

function setupDefaultCinemasData {
  docker exec -i $DB_HOST bash -c 'mongo -u '$DB_ADMIN_USER' -p '$DB_ADMIN_PASS' --authenticationDatabase "admin" < /data/admin/movies.js'
  docker exec -i $DB_HOST mongoimport --db cinemas --collection cinemas --file /data/admin/cinemas.json -u $CINEMA_DBUSER -p $CINEMA_DBPASS --authenticationDatabase=admin --jsonArray
  docker exec -i $DB_HOST mongoimport --db cinemas --collection cities --file /data/admin/cities.json -u $CINEMA_DBUSER -p $CINEMA_DBPASS --authenticationDatabase=admin --jsonArray
  docker exec -i $DB_HOST mongoimport --db cinemas --collection countries --file /data/admin/countries.json -u $CINEMA_DBUSER -p $CINEMA_DBPASS --authenticationDatabase=admin --jsonArray
  docker exec -i $DB_HOST mongoimport --db cinemas --collection states --file /data/admin/states.json -u $CINEMA_DBUSER -p $CINEMA_DBPASS --authenticationDatabase=admin --jsonArray
}

function createDBUsers {
  docker exec -i $DB_HOST bash -c 'mongo -u '$DB_ADMIN_USER' -p '$DB_ADMIN_PASS' --authenticationDatabase "admin" < /data/admin/grantRole.js'
  docker exec -i $DB_HOST mongo admin -u $DB_ADMIN_USER -p $DB_ADMIN_PASS --eval "db.createUser({ user: '$BOOKSTORE_DBUSER', pwd: '$BOOKSTORE_DBPASS', roles: [ { role: 'dbOwner', db: 'bookstore' } ] })"
  docker exec -i $DB_HOST mongo admin -u $DB_ADMIN_USER -p $DB_ADMIN_PASS --eval "db.createUser({ user: '$CINEMA_DBUSER', pwd: '$CINEMA_DBPASS', roles: [ { role: 'dbOwner', db: 'cinemas' } ] })"
}

function isPrimary {
  # primary=$(docker exec -i $DB_HOST bash -c 'mongo -u '$DB_REPLICA_ADMIN' -p '$DB_REPLICA_ADMIN_PASS' --eval "rs.status().members.find(r=>r.state===1).name" --authenticationDatabase "admin"')  
  # primary=`echo $primary | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sed -n 2p`

  if [ $IP == $DB1 ] 
  then
    echo "Setting DB1 as primary"
    init
  else 
    echo "im not primary"
  fi
}

function init {
  init_replica_set
  echo ">>>>>>>>>>> waiting for mongodb to init"
  sleep 5
  add_replicas
  sleep 5
  check_status
  createDBUsers
  sleep 3
  setupDefaultBookStoreData
  sleep 3
  setupDefaultCinemasData
  echo ">>>>>>>>>>> mongodb cluster setup complete"
}

isPrimary