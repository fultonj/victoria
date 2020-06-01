#!/bin/bash
# tag nodes in Ironic
source ~/stackrc

declare -A MAP
MAP[oc0-controller-0]="0-controller-0"  # Controller
MAP[oc0-controller-1]="0-controller-1"  # Controller
MAP[oc0-controller-2]="0-controller-2"  # Controller
MAP[oc0-ceph-0]="0-compute-0"           # Compute
MAP[oc0-ceph-1]="0-compute-1"           # Compute
MAP[oc0-ceph-2]="0-compute-2"           # Compute
MAP[oc0-compute-0]="0-ignore-0"         # ignore
MAP[oc0-compute-1]="0-ignore-1"         # ignore


for K in "${!MAP[@]}"; do
    echo "$K ---> ${MAP[$K]}";
    openstack baremetal node set $K \
              --property capabilities="node:${MAP[$K]},boot_option:local"
    openstack baremetal node show $K -f value | grep cap 
done
