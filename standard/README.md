# Standard Deployment

## What do you get

An overcloud deployed with network isolation containing:

- 3 controller
- 2 compute
- 3 ceph-storage

It uses [metal.yaml](metal.yaml) which is a minimal topology with
three nodes or [metal-big.yaml](metal-big.yaml) which deploys eight
nodes. All overrides are in [overrides.yaml](overrides.yaml).

## How to do it

Set flags in [deploy.sh](deploy.sh) to: 

- provision the baremetal
- create a heat stack
- download the configuration as ansible playbooks
- use ansible to configure the overcloud

<!-- Use [validate.sh](validate.sh) to transfer files to the controller -->
<!-- node and run a validation (this is only necessary since the undercloud -->
<!-- cannot reach the "external" network where the overcloud services -->
<!-- listen). The validation then: -->

<!-- - Reports on Ceph status -->
<!-- - Creates a Cinder volume (and shows it in ceph volumes pool) -->
<!-- - Creates a Glance image (and shows it in ceph images pool) -->
<!-- - Creates a private Neutron network -->
<!-- - Creates a Nova instance -->
