#!/usr/bin/env bash

. /etc/environment

function saveIptables {
  netfilter-persistent save
  netfilter-persistent reload
}
