# /bin/bash
chmod +x environment.sh

# add aws keys
AWS_ACCESS_KEY=
AWS_SECRET_KEY=

function buildImage {
  export MACHINE_TYPE=$1
  /usr/local/bin/packer build -force $2.json
}

# example buildImage bastionvm aws 
buildImage mongodb aws 