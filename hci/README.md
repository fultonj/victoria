# HCI Deployment

## What do you get

An overcloud deployed with network isolation containing:

- 3 controller
- 3 compute hci

Nearly all overrides are in [overrides.yaml](overrides.yaml).

Run [no-metalsmith.sh](no-metalsmith.sh) and then ensure
[deploy.sh](deploy.sh) uses [no-metalsmith.yaml](no-metalsmith.yaml).

Use [validate.sh](validate.sh) to run the following tests on the
deployed overcloud:

- Report on Ceph status
- Create a Cinder volume (and show it in ceph volumes pool)
- Create a Glance image (and show it in ceph images pool)
- Create a private Neutron network
- Create a Nova instance
