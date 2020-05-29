#!/bin/bash

METAL=1
HEAT=1
DOWN=1
NET=1
CEPH=1
CONF=0

STACK=oc0
DIR=config-download
NODE_COUNT=6

source ~/stackrc
# -------------------------------------------------------
if [[ $METAL -eq 1 ]]; then
    # 4 minutes
    openstack overcloud node provision \
              --stack $STACK \
              --output deployed-metal.yaml \
              metal.yaml
fi
# -------------------------------------------------------
if [[ $HEAT -eq 1 ]]; then
    # 7 minutes
    if [[ ! -d ~/templates ]]; then
        ln -s /usr/share/openstack-tripleo-heat-templates templates
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
         -e deployed-metal.yaml \
         -e ~/templates/environments/net-multiple-nics.yaml \
         -e ~/templates/environments/network-isolation.yaml \
         -e ~/templates/environments/network-environment.yaml \
         -e ~/templates/environments/disable-telemetry.yaml \
         -e ~/templates/environments/low-memory-usage.yaml \
         -e ~/templates/environments/enable-swap.yaml \
         -e ~/templates/environments/podman.yaml \
         -e ~/templates/environments/ceph-ansible/ceph-ansible-external.yaml \
         -e ~/generated-container-prepare.yaml \
         -e ~/domain.yaml \
         -e overrides.yaml \
         --libvirt-type qemu \
         --stack-only
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
if [[ ! -d $DIR ]]; then
    echo "tripleo-config-download cmd didn't create $DIR"
    exit 1;
fi
# -------------------------------------------------------
if [[ $NET -eq 1 ]]; then
    # 13 minutes
    pushd $DIR
    time ansible-playbook-3 \
	 -v -b -i tripleo-ansible-inventory.yaml \
         --private-key ~/.ssh/id_rsa_tripleo \
         --skip-tags step2,step3,step4,step5,opendev-validation \
	 deploy_steps_playbook.yaml
   popd
fi
# -------------------------------------------------------
if [[ $CEPH -eq 1 ]]; then
    ANS=/home/stack/tripleo-ceph/
    INV=$ANS/inventory.yaml
    if [[ ! -d $ANS ]]; then
        echo "Fail: clone https://github.com/fmount/tripleo-ceph/ to $ANS"
        exit 1
    fi
    cp $DIR/tripleo-ansible-inventory.yaml $INV
    sed -i $INV -e s/Controller/mons/g -e s/Compute/osds/g
    ansible -m shell -b -a "ip -o -4 a | grep -E 'vlan1(1|2)'" -i $INV mons,osds
    pushd $ANS
    ansible-playbook -i $INV site.yaml -v \
                     --skip-tags ceph_spec,ceph_spec_apply
    popd
fi
# -------------------------------------------------------
if [[ $CONF -eq 1 ]]; then
    pushd $DIR
    time ansible-playbook-3 \
	 -v -b -i tripleo-ansible-inventory.yaml \
         --private-key ~/.ssh/id_rsa_tripleo \
         --tags step2,step3,step4,step5,opendev-validation \
	 deploy_steps_playbook.yaml
   popd
fi
