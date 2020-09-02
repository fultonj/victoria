# HCI Deployment

## What do you get

An overcloud deployed with network isolation containing:

- 3 controller
- 3 compute hci

Nearly all overrides are in [overrides.yaml](overrides.yaml).

Run [no-metalsmith.sh](no-metalsmith.sh) and then ensure
[deploy.sh](deploy.sh) uses [no-metalsmith.yaml](no-metalsmith.yaml).
This no-metalsmith script and template use nova scheduler hints based
on profile to flavor mappings and not node to index mappings.

This deployment also uses derived parameters and exercises the
[tripleo_derive_hci_parameters](https://review.opendev.org/#/c/746595)
ansible module.

Use [validate.sh](validate.sh) to run the following tests on the
deployed overcloud:

- Report on Ceph status
- Create a Cinder volume (and show it in ceph volumes pool)
- Create a Glance image (and show it in ceph images pool)
- Create a private Neutron network
- Create a Nova instance
