#!/usr/bin/bash
# Sets up skeleton for local module development as per:
# https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html

DIR=scratch
KILL=1
MYMODNAME=tripleo_derive_hci_parameters
MYMODPATH=~/git/openstack/tripleo-ansible/tripleo_ansible/ansible_plugins/modules
MYMODFILE="$MYMODNAME.py"
MYARGSFILE=args.json

# preare scratch directory to work in
if [[ $KILL -eq 1 ]]; then
    rm -rf $DIR
fi
if [[ ! -d $DIR ]]; then
    mkdir $DIR
fi
pushd $DIR

# Prepare ansible for development
if [[ $KILL -eq 1 ]]; then
    rm -rf ansible
fi
if [[ ! -d $DIR ]]; then
    git clone https://github.com/ansible/ansible.git
fi
pushd ansible

python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
. hacking/env-setup

# Get my module
cp $MYMODPATH/$MYMODFILE lib/ansible/modules/

# Get my arguments
cp ../../args.json .

# Get a playbook to run it with
cp ../../testmod.yml .

echo "cd $PWD"
echo ". venv/bin/activate"
echo ". hacking/env-setup"
echo "python -m ansible.modules.$MYMODNAME args.json | jq ."
echo ""
echo "ansible-playbook testmod.yml"
echo ""
echo ""

popd # from ansible
popd # from $DIR
