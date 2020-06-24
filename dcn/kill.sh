#!/bin/bash

for STACK in $(openstack stack list -f value -c "Stack Name"); do
    openstack overcloud delete $STACK --yes
done

rm -f control-plane/ceph_keys.yaml
rm -f control-plane/ceph_keys_update.yaml
rm -f ~/control-plane-export.yaml
rm -f ~/dcn_ceph_keys.yaml
