#!/usr/bin/env bash
# Assumes you have run ironic.sh
CONTROL=1
EXPORT=1
DCN0=1
DCN1=1
CONTROLUP=1

source ~/stackrc
# -------------------------------------------------------
if [[ $CONTROL -eq 1 ]]; then
    echo "Standing up control-plane deployment"
    pushd control-plane
    bash deploy.sh
    popd

    echo "Verify control-plane is working"
    RC=/home/stack/control-planerc
    if [[ -e $RC ]]; then
        source $RC
        echo "Attempting to issue token from control-plane"
        openstack token issue -f value -c id
        if [[ $? -gt 0 ]]; then
            echo "Unable to issue token. Aborting."
            exit 1
        fi
        # Use undercloud by default
        source ~/stackrc
    else
        echo "$RC is missing. abort."
        exit 1
    fi
fi
# -------------------------------------------------------
if [[ $EXPORT -eq 1 ]]; then
    openstack overcloud export -f --stack control-plane
    openstack overcloud export ceph -f --stack control-plane

    if [[ ! -e control-plane-export.yaml ]]; then
        echo "Unable to create control-plane-export.yaml. Aborting."
        exit 1
    fi
    if [[ ! -e ceph-export-control-plane.yaml ]]; then
        echo "Failure: openstack overcloud export ceph --stack control-plane"
        exit 1
    fi
fi
# -------------------------------------------------------
if [[ $DCN0 -eq 1 ]]; then
    echo "Standing up dcn0 deployment"
    pushd dcn0
    bash deploy.sh
    if [[ $? -gt 0 ]]; then
        echo "DCN deployment failed. Aborting."
        exit 1
    fi
    popd
fi
# -------------------------------------------------------
if [[ $DCN1 -eq 1 ]]; then
    echo "Standing up dcn1 deployment"
    bash dcnN.sh
fi
# -------------------------------------------------------
if [[ $CONTROLUP -eq 1 ]]; then
    echo "Create control-plane/ceph_keys_update.yaml with ceph_keys.sh 3"
    openstack overcloud export ceph -f --stack dcn0,dcn1
    if [[ ! -e ceph-export-2-stacks.yaml ]]; then
        echo "Failure: openstack overcloud export ceph --stack dcn0,dcn1"
        exit 1
    fi
    echo ""
    echo "Three more steps required to continue:"
    echo ""
    echo "1. Update control-plane/deploy.sh to use ceph-export-2-stacks.yaml"
    echo "2. Update control-plane/deploy.sh to use control-plane/glance_update.yaml"
    echo "3. Re-run control-plane/deploy.sh"
    echo "You may then test the deployment with use-multistore-glance.sh"
fi
