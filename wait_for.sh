#!/bin/bash

while ! ping -q -c 1 "$2" >/dev/null ;
do
  sleep 1;
done
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u "$1" -i "$2," --private-key ~/.ssh/id_rsa ./ansible/playbook.yml