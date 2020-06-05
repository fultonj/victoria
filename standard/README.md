# Standard Deployment

## What do you get

An overcloud deployed with network isolation containing:

- 3 controller
- 2 compute
- 3 ceph-storage

Nearly all overrides are in [overrides.yaml](overrides.yaml).

The virtual baremetal serviers may be deployed in one of two ways.
Either run [no-metalsmith.sh](no-metalsmith.sh) and then modify
[deploy.sh](deploy.sh) to use [no-metalsmith.yaml](no-metalsmith.yaml).
XOR modify [deploy.sh](deploy.sh) to use [metal.yaml](metal.yaml)
(for 3 nodes) or use [metal-big.yaml](metal-big.yaml) (for 8 nodes).

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
