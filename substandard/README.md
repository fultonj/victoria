# Substandard Deployment

## What do you get

An overcloud deployed with network isolation containing:

- 1 controller
- 1 compute

The name is a joke. Normally I have a standard deployment with at
least one Ceph cluster but because I'm getting used to metalsmith
and predeployed servers I use this to go back to basics and leave out
Ceph for now.

It uses [metal.yaml](metal.yaml) which is a minimal topology which
could be in [metalsmith](../metalsmith). This example includes the
[deployed-metal.yaml](deployed-metal.yaml) which is genereated by the 
METAL section of [deploy.sh](deploy.sh) just as an example for others.
It will be backed up and renamed when you actually run the deploy script.
All overrides are in [overrides.yaml](overrides.yaml) (but they are
very minimal).

## How to do it

Set flags in [deploy.sh](deploy.sh) to: 

- provision the baremetal
- create a heat stack
- download the configuration as ansible playbooks
- use ansible to configure the overcloud
