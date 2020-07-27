#!/bin/bash

CLEAN=1
if [[ $CLEAN -eq 1 ]]; then
    cat /dev/null > /tmp/to_clean
    for S in $(openstack server list -f value -c Name | grep ceph); do
        echo $S | sed s/oc// >> /tmp/to_clean
    done
fi

openstack overcloud delete oc0 --yes
#openstack overcloud node unprovision --yes --all --stack oc0 metal-big.yaml

if [[ $CLEAN -eq 1 ]]; then
    for S in $(cat /tmp/to_clean); do
        bash ../metalsmith/clean-disks.sh $S
    done
    rm /tmp/to_clean
fi
