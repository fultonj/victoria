# Standard Deployment

## What do you get

An overcloud deployed with network isolation containing:

- 1 controller
- 1 compute
- 1 ceph-storage

You get the above because of 
[standard-small.yaml](../metalsmith/standard-small.yaml).
You can also have a respective 3,2,3 node count distribution as per
[standard.yaml](../metalsmith/standard.yaml). All overrides are in
[overrides.yaml](overrides.yaml).

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
