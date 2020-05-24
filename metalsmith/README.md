# metalsmith

## Context

In Victoria we're supposed to be switching to using metalsmith and it
should already be working in Ussuri as described in the TripleO doc
[Provisioning Baremetal Before Overcloud Deploy](https://docs.openstack.org/project-deploy-guide/tripleo-docs/latest/provisioning/baremetal_provision.html).

I created my environment with the contents of 
[environments/metalsmith.yaml](https://github.com/cjeanner/tripleo-lab/blob/master/environments/metalsmith.yaml)
in my [tripleo-lab/overrides.yml](../tripleo-lab/overrides.yml)
and though I have a working undercloud it seems introspection 
was skipped (intentionally?).

```
TASK [overcloud : Fail if baremetal.json doesn't exist] ***********************
Saturday 23 May 2020  23:05:08 -0400 (0:00:00.510)       0:42:35.382 ********** 
fatal: [undercloud]: FAILED! => {"changed": false, "msg": "Playbook
didn't generate baremetal.json.\nThis might be due to the lack of
parameter.\nPlease re-run, ensuring -t domains is passed!\n"}
```

## Attempts to get metalsmith working

todo...
