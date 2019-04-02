# /bin/bash
chmod +x environment.sh

. ./environment.sh

function buildImage {
  export MACHINE_TYPE=$1
  /usr/local/bin/packer build -force $2.json
}

# buildImage ncv aws  
# buildImage ch aws 
# buildImage proxyvm aws 
buildImage mongodb aws 
# wait # waits for all background processes to complete