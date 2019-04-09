# /bin/bash
chmod +x environment.sh

. ./environment.sh

function buildImage {
  export MACHINE_TYPE=$1
  /usr/local/bin/packer build -force $2.json
}

# example buildImage bastionvm aws 
buildImage mongodb aws 