#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

function createDockerVolume {
  cmd=$(docker volume ls -q | grep $1)
  if [[ "$cmd" == $1 ]];
  then
    echo 'volume available'
  else
    cmd='docker volume create --name '$1
    eval $cmd
    echo '·· mongodb volume created >>>> '$1' ··'
  fi
}

function copyFilesToContainer {
  echo '·· copying files to container >>>> '$1' ··'

  sudo chmod 600 /var/mongo/mongo-keyfile

  # copy necessary files
  docker cp /var/mongo/admin.js $1:/data/admin/
  docker cp /var/mongo/replica.js $1:/data/admin/
  docker cp /var/mongo/mongo-keyfile $1:/data/keyfile/
  docker cp /var/mongo/grantRole.js $1:/data/admin
  
  docker cp /var/mongo/db_test/cinemas/movies.js $1:/data/admin
  docker cp /var/mongo/db_test/cinemas/cinemas.json $1:/data/admin
  docker cp /var/mongo/db_test/cinemas/cities.json $1:/data/admin
  docker cp /var/mongo/db_test/cinemas/countries.json $1:/data/admin
  docker cp /var/mongo/db_test/cinemas/states.json $1:/data/admin
  
  docker cp /var/mongo/db_test/bookstore/authors.json $1:/data/admin
  docker cp /var/mongo/db_test/bookstore/books.json $1:/data/admin
  docker cp /var/mongo/db_test/bookstore/category.json $1:/data/admin
  docker cp /var/mongo/db_test/bookstore/publisher.json $1:/data/admin
  echo '·· copying files to container done >>>> '$1' ··'
}

# @params container volume
function configMongoContainer {
  echo '·· configuring container >>>> '$1' ··'

  # check if volume exists
  createDockerVolume $2

  # start container
  docker run --name $1 -v $2:/data -d mongo --smallfiles

  # create the folders necessary for the container
  docker exec -i $1 bash -c 'mkdir /data/keyfile /data/admin'

  # copy the necessary files to the container
  copyFilesToContainer $1

  # change folder owner to the current container user
  docker exec -i $1 bash -c 'chown -R mongodb:mongodb /data'

  echo '·· configuring container done >>>> '$1' ··'
}

# @params server container volume
function createMongoDBNode {
  echo '·· creating container >>>> '$1' ··'

  # start configuration of the container
  configMongoContainer $1 $2

  sleep 2

  echo '·· removing pre container >>>> '$1' ··'

  # remove container
  docker rm -f $1
}

createMongoDBNode mongo_container mongo_storage