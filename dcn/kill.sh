#!/bin/bash

for STACK in $(openstack stack list -f value -c "Stack Name"); do
    openstack overcloud delete $STACK --yes
done
