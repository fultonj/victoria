#!/bin/bash

METAL=1
HEAT=1
DOWN=0
CHECK=0
LOG=1

STACK=oc0
DIR=~/config-download
NODE_COUNT=8

source ~/stackrc
# -------------------------------------------------------
if [[ $(($HEAT + $DOWN)) -gt 1 ]]; then
    echo "HEAT ($HEAT) and DOWN ($DOWN) cannot both be 1."
    echo "HEAT will run config-download the first time."
    echo "Only use DOWN for subsequent config-download runs."
    exit 1
fi
# -------------------------------------------------------
if [[ $METAL -eq 1 ]]; then
    openstack overcloud node provision \
              --stack $STACK \
              --output deployed-metal-big.yaml \
              metal-big.yaml

    sed -i s/\\/usr\\/share\\/openstack\\-tripleo\\-heat\\-/..\\/..\\//g \
        deployed-metal-big.yaml
else
    echo "Assuming servers are provsioned"
fi
# -------------------------------------------------------
# `openstack overcloud -v` should be passed along as
# `ansible-playbook -vv` for any usage of Ansible (the
# OpenStack client defaults to no -v being 1 verbosity
# and --quiet being 0)
# -------------------------------------------------------
if [[ $HEAT -eq 1 ]]; then
    # tripleo-client will use ansible to run heat and config-download
    if [[ ! -d ~/templates ]]; then
        ln -s /usr/share/openstack-tripleo-heat-templates ~/templates
    fi
    if [[ $NODE_COUNT -gt 0 ]]; then
        FOUND_COUNT=$(metalsmith -f value -c "Hostname" list | wc -l)
        if [[ $NODE_COUNT != $FOUND_COUNT ]]; then
            echo "Expecting $NODE_COUNT nodes but $FOUND_COUNT nodes have been deployed"
            exit 1
        fi
    fi
    
    time openstack overcloud \-v deploy \
          --disable-validations \
          --deployed-server \
          --libvirt-type qemu \
          --stack $STACK \
          --templates ~/templates \
          -r roles.yaml \
          -n ../network-data.yaml \
          -e ~/templates/environments/deployed-server-environment.yaml \
          -e ~/templates/environments/network-isolation.yaml \
          -e ~/templates/environments/network-environment.yaml \
          -e ~/templates/environments/disable-telemetry.yaml \
          -e ~/templates/environments/low-memory-usage.yaml \
          -e ~/templates/environments/enable-swap.yaml \
          -e ~/templates/environments/ceph-ansible/ceph-ansible.yaml \
          -e ~/templates/environments/docker-ha.yaml \
          -e ~/templates/environments/podman.yaml \
          -e ~/containers-prepare-parameter.yaml \
          -e ~/generated-container-prepare.yaml \
          -e ~/oc0-domain.yaml \
          -e deployed-metal-big.yaml \
          -e overrides.yaml
fi
# -------------------------------------------------------
if [[ $DOWN -eq 1 ]]; then
    INV=tripleo-ansible-inventory.yaml
    if [[ ! -d $DIR/$STACK ]]; then
        echo "$DIR/$STACK does not exist, Create it by setting HEAT=1"
        exit 1
    fi
    pushd $DIR/$STACK

    if [[ $LOG -eq 1 ]]; then
        if [[ ! -d ~/log ]]; then
            mkdir ~/log
        fi
        EXT=$(date +%F_%T)
        echo "Rotate the logs"
        for L in ~/ansible.log ~/config-download/config-download-latest/ceph-ansible/ceph_ansible_command.log; do
            if [[ -e $L ]]; then
                DST=$(basename $L)
                mv $L ~/log/$DST.$EXT
            fi
        done
    fi

    if [[ $CHECK -eq 1 ]]; then
        if [[ ! -e ~/.ssh/id_rsa_tripleo ]]; then
            cp ~/.ssh/id_rsa ~/.ssh/id_rsa_tripleo
        fi
        if [[ ! -e $INV ]]; then
            echo "$INV does not exist, Create it by setting HEAT=1"
            exit 1
        fi
        echo "Test ansible ping"
        ansible -i $INV all -m ping
        echo "pushd $DIR/$STACK"
        echo 'ansible -i tripleo-ansible-inventory.yaml all -m shell -b -a "hostname"'

        # # check that the inventory will work for ceph roles
        # ansible -i $INV -m ping ceph_mon
        # ansible -i $INV -m ping ceph_client
        # ansible -i $INV -m ping ceph_osd
        # grep ceph $INV
        # if [[ $(grep osd $INV  | wc -l) == 0 ]]; then
        #     # this happened with metalsmith (need to revisit)
        #     echo "There are no OSDs in the inventory so the deployment will fail."
        #     echo "Exiting early."
        #     exit 1
        # fi

    fi
    # -------------------------------------------------------
    # run it all
    time bash ansible-playbook-command.sh

    # Just re-run ceph
    # time bash ansible-playbook-command.sh --tags external_deploy_steps --skip-tags step4,step5,post_deploy_steps

    # Just re-run ceph prepration without running ceph
    # time bash ansible-playbook-command.sh --tags external_deploy_steps --skip-tags step4,step5,post_deploy_steps,ceph
    
    # Pick up after good ceph install (need to test this)
    # time bash ansible-playbook-command.sh --tags step2,step3,step4,step5,post_deploy_steps,external --skip-tags ceph

   popd
fi

