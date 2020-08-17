# Environment for Derive Parameters Ansible Module

This picks up from the 
[Ussuri derive paramters work](https://github.com/fultonj/ussuri/tree/master/derive)
by providing an environment to develop the 
[tripleo_derive_hci_parameters ansible module](https://review.opendev.org/#/c/746595).
It borrows from Ansible's
[development guide on module writing](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html).

## Local Development

- Run [localdev.sh](localdev.sh) to set up a venv with a copy of the module
- Use the venv:
```
cd scratch/ansible/

. venv/bin/activate
. hacking/env-setup

python -m ansible.modules.tripleo_derive_hci_parameters args.json | jq .

ansible-playbook testmod.yml
```
