#!/bin/bash

METAL=1
HEAT=1
DOWN=1
CHECK=1
CONF=0

STACK=oc0
DIR=config-download
NODE_COUNT=8

source ~/stackrc
# -------------------------------------------------------
if [[ $METAL -eq 1 ]]; then
    # 4 minutes
    openstack overcloud node provision \
              --stack $STACK \
              --output deployed-metal-big.yaml \
              metal-big.yaml
fi
# -------------------------------------------------------
# `openstack overcloud -v` should be passed along as
# `ansible-playbook -vv` for any usage of Ansible (the
# OpenStack client defaults to no -v being 1 verbosity
# and --quiet being 0)
# -------------------------------------------------------
if [[ $HEAT -eq 1 ]]; then
    # 7 minutes
    if [[ ! -d ~/templates ]]; then
        ln -s /usr/share/openstack-tripleo-heat-templates ~/templates
    fi
    FOUND_COUNT=$(metalsmith -f value -c "Hostname" list | wc -l)
    if [[ $NODE_COUNT != $FOUND_COUNT ]]; then
        echo "Expecting $NODE_COUNT nodes but $FOUND_COUNT nodes have been deployed"
        exit 1
    fi
    time openstack overcloud -v deploy \
         --stack $STACK \
         --templates ~/templates/ \
         -n ../network-data.yaml \
         -e ~/templates/environments/deployed-server-environment.yaml \
         -e deployed-metal-big.yaml \
         -e ~/templates/environments/net-multiple-nics.yaml \
         -e ~/templates/environments/network-isolation.yaml \
         -e ~/templates/environments/network-environment.yaml \
         -e ~/templates/environments/disable-telemetry.yaml \
         -e ~/templates/environments/low-memory-usage.yaml \
         -e ~/templates/environments/enable-swap.yaml \
         -e ~/templates/environments/podman.yaml \
         -e ~/templates/environments/ceph-ansible/ceph-ansible.yaml \
         -e ~/generated-container-prepare.yaml \
         -e ~/domain.yaml \
         -e ~/victoria/standard/overrides.yaml \
         --stack-only \
         --libvirt-type qemu

         # remove --stack-only to make DOWN and CONF unnecessary...
fi
# -------------------------------------------------------
if [[ $DOWN -eq 1 ]]; then
    echo "Get status of $STACK from Heat"
    STACK_STATUS=$(openstack stack list -c "Stack Name" -c "Stack Status" \
	-f value | grep $STACK | awk {'print $2'});
    if [[ ! ($STACK_STATUS == "CREATE_COMPLETE" || 
                 $STACK_STATUS == "UPDATE_COMPLETE") ]]; then
	echo "Exiting. Status of $STACK is $STACK_STATUS"
	exit 1
    fi
    if [[ -d $DIR ]]; then rm -rf $DIR; fi
    openstack overcloud config download \
              --name $STACK \
              --config-dir $DIR
    if [[ ! -d $DIR ]]; then
	echo "tripleo-config-download cmd didn't create $DIR"
    else
	pushd $DIR
        if [[ ! -e ansible.cfg ]]; then
            # Assume I don't yet have https://review.opendev.org/#/c/725602
            echo "Genereating ansible.cfg in $PWD"
            openstack tripleo config generate ansible
            if [[ -e ~/ansible.cfg ]]; then
                mv -v ~/ansible.cfg ansible.cfg 
            fi
            if [[ ! -e ansible.cfg ]]; then
                echo "Unable to create ansible.cfg. Giving up."
                exit 1
            fi
        fi
	tripleo-ansible-inventory --static-yaml-inventory \
                                  tripleo-ansible-inventory.yaml \
                                  --stack $STACK
	if [[ ! -e tripleo-ansible-inventory.yaml ]]; then
	    echo "Unable to create inventory. Giving up."
	    exit 1
	fi
        ln -s tripleo-ansible-inventory.yaml inventory.yaml
        echo "Ensure ~/.ssh/id_rsa_tripleo exists"
	if [[ ! -e ~/.ssh/id_rsa_tripleo ]]; then
            cp ~/.ssh/id_rsa ~/.ssh/id_rsa_tripleo
        fi
        echo "Test ansible ping"
	ansible -i tripleo-ansible-inventory.yaml all -m ping
	popd        
	echo "pushd $DIR"
	echo 'ansible -i inventory.yaml all -m shell -b -a "hostname"'
    fi
fi
# -------------------------------------------------------
if [[ $CHECK -eq 1 ]]; then
    pushd $DIR
    ansible -i tripleo-ansible-inventory.yaml -m ping ceph_mon
    ansible -i tripleo-ansible-inventory.yaml -m ping ceph_client
    ansible -i tripleo-ansible-inventory.yaml -m ping ceph_osd
    grep ceph tripleo-ansible-inventory.yaml
    if [[ $(grep osd tripleo-ansible-inventory.yaml  | wc -l) == 0 ]]; then
        echo "There are no OSDs in the inventory so the deployment will fail."
        echo "Exiting early."
        exit 1
    fi
    popd
fi
# -------------------------------------------------------
if [[ $CONF -eq 1 ]]; then
    if [[ ! -d $DIR ]]; then
	echo "tripleo-config-download cmd didn't create $DIR"
        exit 1;
    fi
    #echo "about to execute the following plays:"
    #ansible-playbook $DIR/deploy_steps_playbook.yaml --list-tasks
    pushd $DIR
    time ansible-playbook-3 \
	 -v \
	 --ssh-extra-args "-o StrictHostKeyChecking=no" --timeout 240 \
	 --become \
	 -i tripleo-ansible-inventory.yaml \
         --private-key ~/.ssh/id_rsa_tripleo \
	 deploy_steps_playbook.yaml

         # Just re-run ceph
         # -e gather_facts=true -e @global_vars.yaml \
         # --tags external_deploy_steps \
    
         # Test validations
         # --tags opendev-validation-ceph
    
         # Pick up after good ceph install (need to test this)
         # --tags step2,step3,step4,step5,post_deploy_steps,external --skip-tags ceph
   popd
fi
