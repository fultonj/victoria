#!/bin/bash

CLEAN=0
source ~/stackrc

if [[ $CLEAN -eq 1 ]]; then
    cat /dev/null > /tmp/ironic_names_to_clean
    openstack server list -f value -c Name -c ID | grep hci | awk {'print $1'} > /tmp/nova_ids_to_clean
    cat /dev/null > /tmp/ironic_names_to_clean
    for S in $(cat /tmp/nova_ids_to_clean); do
        openstack baremetal node list -f value -c Name -c "Instance UUID" | grep $S | awk {'print $1'} >> /tmp/ironic_names_to_clean
    done
fi

for STACK in $(openstack stack list -f value -c "Stack Name"); do
    openstack overcloud delete $STACK --yes
done

rm -f control-plane-export.yaml
rm -f ceph-export-control-plane.yaml
rm -f ceph-export-2-stacks.yaml
rm -rf dcn1

if [[ $CLEAN -eq 1 ]]; then
    for S in $(cat /tmp/ironic_names_to_clean); do
        bash ../metalsmith/clean-disks.sh $S
    done
fi
