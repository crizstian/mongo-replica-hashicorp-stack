#!/usr/bin/env bash
. /etc/environment
. /var/aero/util/iptables-helper.sh

function main {
  service docker restart
  updateIpTable
}

function updateIpTable {
  # "2385", # Docker API
  iptables -I INPUT -s 0/0 -p tcp --dport 2385 -j ACCEPT
  # "2375", # Docker SWARM
  iptables -I INPUT -s 0/0 -p tcp --dport 2375 -j ACCEPT
  iptables -P INPUT ACCEPT
  iptables -P FORWARD ACCEPT
  iptables -P OUTPUT ACCEPT
  saveIptables
}

main
