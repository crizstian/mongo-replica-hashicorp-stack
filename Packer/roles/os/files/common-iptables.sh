#!/usr/bin/env bash

. /etc/environment
. /var/cobalt/util/iptables-helper.sh

function main {
  updateIpTable
}

function updateIpTable {
  # "22",   # ssh port
  iptables -I INPUT -s 0/0 -p tcp --dport 22 -j ACCEPT
  # "53",   # DNS port
  iptables -I INPUT -s 0/0 -p tcp --dport 53 -j ACCEPT
  # "53",   # UDP DNS port
  iptables -I INPUT -s 0/0 -p udp --dport 53 -j ACCEPT
  # "27017",   # TCP MONGO port
  iptables -I INPUT -s 0/0 -p tcp --dport 27017 -j ACCEPT

  saveIptables

}

main
