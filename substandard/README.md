# Substandard Deployment

## What do you get

An overcloud deployed with network isolation containing:

- 3 controller
- 2 compute

The name is a joke. Normally I have a standard deployment with at
least one Ceph cluster but because I'm getting used to metalsmith
and predeployed servers I use this to go back to basics and leave out
Ceph for now.

It uses [metal.yaml](metal.yaml) which is a minimal topology with two
nodes or [metal-big.yaml](metal-big.yaml) which deploys five nodes.
This example includes [deployed-metal.yaml](deployed-metal.yaml) and
[deployed-metal-big.yaml](deployed-metal-big.yaml) which is genereated
by the  METAL section of [deploy.sh](deploy.sh) and provided only for 
reference as it is regenereated with each deployment. It will be
backed up and renamed when [deploy.sh](deploy.sh) is run. All
overrides are in [overrides.yaml](overrides.yaml) but they are
minimal.

## How to do it

Set flags in [deploy.sh](deploy.sh) to: 

- provision the baremetal
- create a heat stack
- download the configuration as ansible playbooks
- use ansible to configure the overcloud
