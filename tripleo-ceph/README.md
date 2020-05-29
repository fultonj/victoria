# TripleO Ceph Prototype

POC for [tripleo-ceph spec](https://review.opendev.org/#/c/723108)
which uses POC [tripleo-ceph](https://github.com/fmount/tripleo-ceph) 
Ansible roles.

## What you get

- 1 controller running ceph-{mon,mgr} containers
- 1 compute running ceph-osd containers

You get the functional equivalent of if you had deployed using 
ceph-ansible and the ComputeHCI role. However, the collocated
Ceph deployment is implemented using cephadm and ceph-orchestrator.
Ceph client configuration uses ceph-ansible-external.yaml.

## Deployment Process

Set flags to 0 or 1 in [deploy.sh](deploy.sh) to enable the following:

- METAL provision baremetal with metalsmith
- HEAT create a heat stack with --stack-only
- DOWN download the configuration as ansible playbooks
- NET use config-download ansible to configure the networks
- CEPH deploy ceph with [tripleo-ceph](https://github.com/fmount/tripleo-ceph)
- CONF use config-download ansible to configure the rest of the openstack

## Notes

- https://download.ceph.com/rpm-octopus/el8/x86_64/
- https://github.com/ceph/ceph/pull/35195
- https://github.com/ceph/ceph/pull/34879

## Status

- We can bootstap a ceph-mon and ceph-mgr on a controller node with cephadm
