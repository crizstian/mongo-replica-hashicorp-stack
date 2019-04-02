#!/bin/bash
EC2_INSTANCE_METADATA_URL="http://169.254.169.254/latest/meta-data"
EC2_INSTANCE_DYNAMIC_DATA_URL="http://169.254.169.254/latest/dynamic"

function get_value {
  local readonly path="$1"
  curl --silent --show-error --location "$EC2_INSTANCE_METADATA_URL/$path/"
}

function get_dynamic_data {
  local readonly path="$1"
  curl --silent --show-error --location "$EC2_INSTANCE_DYNAMIC_DATA_URL/$path/"
}

function get_instance_ip_address {
  get_value "local-ipv4"
}

function get_host_name {
  get_value "hostname"
}
