#!/bin/bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the

set -e

# Send the log output from this script to user-data.log, syslog, and the console
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "export DB_ADMIN_USER=${dbAdminUser}" >> /etc/environment
echo "export DB_ADMIN_PASS=${dbAdminUserPass}" >> /etc/environment

echo "export DB_REPLICA_ADMIN=${dbReplicaAdmin}" >> /etc/environment
echo "export DB_REPLICA_ADMIN_PASS=${dbReplicaAdminPass}" >> /etc/environment
echo "export DB_REPLSET_NAME=${dbReplSetName}" >> /etc/environment

echo "export AWS_ACCESS_KEY_ID=${access_key}" >> /etc/environment
echo "export AWS_SECRET_ACCESS_KEY=${secret_key}" >> /etc/environment
echo "export AWS_DEFAULT_REGION=${region}" >> /etc/environment

sudo service mongo start