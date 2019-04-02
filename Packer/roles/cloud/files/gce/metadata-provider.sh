#!/bin/bash
# This script is used to configure and run Consul on a Google Compute Instance.

set -e

readonly COMPUTE_INSTANCE_METADATA_URL="http://metadata.google.internal/computeMetadata/v1"
readonly GOOGLE_CLOUD_METADATA_REQUEST_HEADER="Metadata-Flavor: Google"

# Get the value at a specific Instance Metadata path.
function get_instance_metadata_value() {
  local readonly path="$1"
  curl --silent --show-error --location --header "$GOOGLE_CLOUD_METADATA_REQUEST_HEADER" "$COMPUTE_INSTANCE_METADATA_URL/$path"
}

# Get the value of the given Custom Metadata Key
function get_value() {
  local readonly key="$1"

  get_instance_metadata_value "instance/attributes/$key"
}

# Get the ID of the current Compute Instance
function get_host_name() {
  get_instance_metadata_value "instance/name"
}

# Get the IP Address of the current Compute Instance
function get_instance_ip_address() {
  local network_interface_number="$1"

  # If no network interface number was specified, default to the first one
  if [[ -z "$network_interface_number" ]]; then
    network_interface_number=0
  fi

  get_instance_metadata_value "instance/network-interfaces/$network_interface_number/ip"
}
