#!/bin/bash

# https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/13/html-single/hyperconverged_infrastructure_guide/index#prepare-overcloud-role

source ~/stackrc

declare -A MAP
MAP[oc0-controller-0]="baremetal"  # Controller
MAP[oc0-controller-1]="baremetal"  # Controller
MAP[oc0-controller-2]="baremetal"  # Controller
MAP[oc0-ceph-0]="computeHCI"       # ComputeHCI
MAP[oc0-ceph-1]="computeHCI"       # ComputeHCI
MAP[oc0-ceph-2]="computeHCI"       # ComputeHCI

for K in "${!MAP[@]}"; do
    echo "$K ---> ${MAP[$K]}";
    openstack baremetal node set $K \
              --property capabilities="profile:${MAP[$K]},boot_option:local"
    openstack baremetal node show $K -f value | grep cap 
done

# Create the flavor

openstack flavor list -f value -c Name | grep computeHCI
if [[ $? -eq 0 ]]; then
    echo "The computeHCI flavor already exists"
else
    echo "Need to create the computeHCI flavor"
    openstack flavor create --id auto --ram 6144 --disk 40 --vcpus 4 computeHCI

    openstack flavor set --property "cpu_arch"="x86_64" \
              --property "capabilities:boot_option"="local" \
              --property "resources:CUSTOM_BAREMETAL"="1" \
              --property "resources:DISK_GB"="0" \
              --property "resources:MEMORY_MB"="0" \
              --property "resources:VCPU"="0" computeHCI

    openstack flavor set --property "capabilities:profile"="computeHCI" computeHCI
fi

