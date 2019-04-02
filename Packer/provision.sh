#!/bin/bash -e
export playbook=$1

sudo apt-get upgrade -y
sudo apt-get update
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible -y

cd /var/tmp
sudo ansible-playbook -i "localhost," -c local $playbook
