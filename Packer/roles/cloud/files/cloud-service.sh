#!/bin/bash

function runonce {
  WORKDIR=/var/aero/cloud

  if [ -e "$WORKDIR/done" ]; then
    exit 0
  fi
  detect_cloud_provider

  #TODO: Avoid using hard coded path
  . $WORKDIR/cloud-helper/$provider_type/metadata-provider.sh
  update_environment

  # Run all user supplied systemd_scripts
  for userscript in $(ls $WORKDIR/user-scripts); do
    bash $WORKDIR/user-scripts/$userscript
  done
}

function detect_cloud_provider {
  response=0
  # based on https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/identify_ec2_instances.html
  if [ -e /sys/hypervisor/uuid ]; then
    response=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)
  fi
  FLAG_FILE="$WORKDIR/done"

  if [ ${response} -eq 1 ]; then
    echo "export provider_type=aws" | sudo tee -a /etc/environment
    export provider_type=aws
    touch "$FLAG_FILE"
  else
    # based on https://cloud.google.com/compute/docs/instances/managing-instances#runninggce
    response=$(sudo dmidecode -s bios-vendor i | grep "Google" | wc -l)
    if [ ${response} -eq 1 ]; then
      echo "export provider_type=gce" | sudo tee -a /etc/environment
      export provider_type=gce
      touch "$FLAG_FILE"
    else
      echo "unsupported provider"
      exit 1
    fi
  fi
}

function update_environment {
  echo "export ip4_add=$(get_instance_ip_address)" >>/etc/environment
  hostnamefromcloud=$(get_host_name)
  host=$(echo ${hostnamefromcloud%%.*} | sed -e 's/ip-//' -e 's/-/./g' -e 's/\./-/g')
  echo "export hostname=$(echo $host)" >>/etc/environment
  echo "$host" >/etc/hostname
}

runonce
