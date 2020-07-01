#!/bin/bash

HEAT=1
DOWN=0
CONF=0

STACK=dcn0
DIR=$PWD/config-download

source ~/stackrc

# -------------------------------------------------------
export ANSIBLE_CONFIG=/home/stack/ansible.cfg
if [[ ! -e $ANSIBLE_CONFIG ]]; then
    openstack tripleo config generate ansible
    if [[ ! -e $ANSIBLE_CONFIG ]]; then
        echo "Unable to create $ANSIBLE_CONFIG"
        exit 1;
    fi
fi
# -------------------------------------------------------
if [[ ! -e ~/dcn_roles.yaml ]]; then
    openstack overcloud roles generate DistributedComputeHCI DistributedComputeHCIScaleOut -o ~/dcn_roles.yaml
fi
# -------------------------------------------------------
# `openstack overcloud -v` should be passed along as
# `ansible-playbook -vv` for any usage of Ansible (the
# OpenStack client defaults to no -v being 1 verbosity
# and --quiet being 0)
# -------------------------------------------------------
if [[ $HEAT -eq 1 ]]; then
    if [[ ! -d ~/templates ]]; then
        ln -s /usr/share/openstack-tripleo-heat-templates ~/templates
    fi
    time openstack overcloud -v deploy \
         --stack $STACK \
         --override-ansible-cfg $ANSIBLE_CONFIG \
         --config-download-timeout 240 \
         --templates ~/templates/ \
         -r ~/dcn_roles.yaml \
         -n ~/victoria/network-data.yaml \
         -e ~/templates/environments/net-multiple-nics.yaml \
         -e ~/templates/environments/network-isolation.yaml \
         -e ~/templates/environments/network-environment.yaml \
         -e ~/templates/environments/disable-telemetry.yaml \
         -e ~/templates/environments/low-memory-usage.yaml \
         -e ~/templates/environments/enable-swap.yaml \
         -e ~/templates/environments/podman.yaml \
         -e ~/templates/environments/ceph-ansible/ceph-ansible.yaml \
         -e ~/templates/environments/dcn-hci.yaml \
         -e ~/generated-container-prepare.yaml \
         -e ~/control-plane-export.yaml \
         -e ~/dcn_ceph_keys.yaml \
         -e ~/victoria/dcn/dcn0/ceph.yaml \
         -e ~/victoria/dcn/dcn0/nova-az.yaml \
         -e ~/victoria/dcn/dcn0/glance.yaml \
         -e ~/victoria/dcn/dcn0/overrides.yaml \
         --libvirt-type qemu 2>&1 | tee -a ~/install-overcloud.log

    # remove --no-config-download to make DOWN and CONF unnecessary
    # --stack-only \
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
	pushd $DIR/$STACK
	tripleo-ansible-inventory --static-yaml-inventory inventory.yaml --stack $STACK
	if [[ ! -e inventory.yaml ]]; then
	    echo "No inventory. Giving up."
	    exit 1
	fi
        echo "Ensure ~/.ssh/id_rsa_tripleo exists"
	if [[ ! -e ~/.ssh/id_rsa_tripleo ]]; then
            cp ~/.ssh/id_rsa ~/.ssh/id_rsa_tripleo
        fi
        echo "Test ansible ping"
        echo "Running ansible with ANSIBLE_CONFIG=$ANSIBLE_CONFIG"
	ansible -i inventory.yaml all -m ping
	popd
        echo "export ANSIBLE_CONFIG=/home/stack/ansible.cfg"
	echo "pushd $DIR/$STACK"
	echo 'ansible -i inventory.yaml all -m shell -b -a "hostname"'
    fi
fi
# -------------------------------------------------------
if [[ $CONF -eq 1 ]]; then
    if [[ ! -d $DIR ]]; then
	echo "tripleo-config-download cmd didn't create $DIR"
        exit 1;
    fi
    echo "Running ansible with ANSIBLE_CONFIG=$ANSIBLE_CONFIG"
    time ansible-playbook-3 \
	 -v \
	 --become \
	 -i $DIR/$STACK/inventory.yaml \
	 $DIR/$STACK/deploy_steps_playbook.yaml

         # Just re-run ceph
         # --tags external_deploy_steps

         # Test validations
         # --tags opendev-validation-ceph
    
         # Pick up after good ceph install (need to test this)
         # --tags step2,step3,step4,step5,post_deploy_steps,external --skip-tags ceph
fi
