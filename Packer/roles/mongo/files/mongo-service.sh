#!/bin/bash
# Send the log output from this script to user-data.log, syslog, and the console

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

. /etc/environment

DB_HOST=`echo ${hostname} | sed -e 's/ip-//'`
IP=`ip -f inet addr show $(ip -f inet route show | grep default | awk '{ print $5 }') | grep -Po 'inet \K[\d.]+'`
DB_PORT=27017
BOOKSTORE_DBUSER=bookstore
BOOKSTORE_DBPASS=bookstorepass1
CINEMA_DBUSER=cinemas
CINEMA_DBPASS=cinemaspass1

echo "export DB_HOST=${DB_HOST}" >> /etc/environment
echo "export IP=${IP}" >> /etc/environment
echo "export DB_PORT=${DB_PORT}" >> /etc/environment
echo "export BOOKSTORE_DBUSER=${BOOKSTORE_DBUSER}" >> /etc/environment
echo "export BOOKSTORE_DBPASS=${BOOKSTORE_DBPASS}" >> /etc/environment
echo "export CINEMA_DBUSER=${CINEMA_DBUSER}" >> /etc/environment
echo "export CINEMA_DBPASS=${CINEMA_DBPASS}" >> /etc/environment


DBS=`aws ec2 describe-instances --filters "Name=tag:Name,Values=*Mongo*" --query 'Reservations[].Instances[].PrivateIpAddress' --region $AWS_DEFAULT_REGION`
DB1=`echo $DBS | jq .[0] | sed -e 's/"//g'`
DB2=`echo $DBS | jq .[1] | sed -e 's/"//g'`
DB3=`echo $DBS | jq .[2] | sed -e 's/"//g'`

echo "export DB1=${DB1}" >> /etc/environment
echo "export DB2=${DB2}" >> /etc/environment
echo "export DB3=${DB3}" >> /etc/environment

export GOMAXPROCS=$(nproc)

consul-template -template "/var/mongo/admin.js.ctmpl:/var/mongo/admin.js" -once
consul-template -template "/var/mongo/grantRole.js.ctmpl:/var/mongo/grantRole.js" -once
consul-template -template "/var/mongo/replica.js.ctmpl:/var/mongo/replica.js" -once

cat > /var/mongo/hosts.sh <<EOF
. /etc/environment

function howManyServers {
  arg=''
  arg=\$arg' --add-host '\$DB1':'\$DB1
  arg=\$arg' --add-host '\$DB2':'\$DB2
  arg=\$arg' --add-host '\$DB3':'\$DB3

  echo \$arg
}
EOF

echo '·· Pre-Start executed >>>> ··'
bash /var/mongo/pre-start.sh
sleep 20
echo '·· Pre-Start done >>>> ··'
echo '·· Starting DB Service >>>> ··'
bash /var/mongo/start.sh
sleep 20
echo '·· DB Service Started >>>> ··'
echo '·· Detecting Primary DB >>>> ··'
bash /var/mongo/primary-db-only.sh
echo '·· Detecting Primary Done >>>> ··'
