#!/bin/bash

set -e

echo root | ssh alarm@$2 "/bin/bash -c 'su -c \"pacman -Sy --noconfirm --needed sudo python python-simplejson\"'"

grep -qF $1 hosts || echo "$1" >> hosts

ansible-playbook \
    --user alarm  \
    --become-method=su \
    --limit $1 \
    --extra-vars ansible_ssh_pass=alarm \
    -e ansible_become_pass=root  \
    -e ansible_host=$2 \
    setup.yml

echo "$1 done
