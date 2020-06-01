# TripleO Ceph Proof of Concept

POC for [tripleo-ceph spec](https://review.opendev.org/#/c/723108)
which uses [tripleo-ceph](https://github.com/fmount/tripleo-ceph)
Ansible roles.

## What you get

- 3 controllers running ceph-{mon,mgr} containers
- 3 computes running ceph-osd containers (+2 extra mons)

You get the functional equivalent of if you had deployed using 
ceph-ansible and the ComputeHCI role. However, the collocated
Ceph deployment is implemented using cephadm and ceph-orchestrator

## Deployment Process

Set flags to 0 or 1 in [deploy.sh](deploy.sh) to enable the following:

- METAL provision baremetal with metalsmith
- HEAT create a heat stack with --stack-only
- DOWN download the configuration as ansible playbooks
- NET use config-download ansible to configure the networks
- CEPH deploy ceph with [tripleo-ceph](https://github.com/fmount/tripleo-ceph)
- CONF use config-download ansible to configure the rest of the openstack

## Does it work? 

Yes

### Ceph works

My [deploy.sh](deploy.sh) deployed a 6-node HCI overcloud based where
Ceph was configured by cephadm and orechestrator.

```
[root@oc0-controller-0 ~]# cephadm shell
INFO:cephadm:Inferring fsid aa93aa4c-a444-11ea-8751-24420017ffbd
INFO:cephadm:Using recent ceph image docker.io/ceph/ceph:v15
0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# ceph -s
  cluster:
    id:     aa93aa4c-a444-11ea-8751-24420017ffbd
    health: HEALTH_OK
 
  services:
    mon: 5 daemons, quorum oc0-controller-0,oc0-compute-1,oc0-compute-0,oc0-controller-1,oc0-compute-2 (
age 2m)                                                                                                
    mgr: oc0-controller-0.tahqsp(active, since 6m), standbys: oc0-controller-0.jmvpvw, oc0-controller-1.
urpqps                                                                                                 
    osd: 12 osds: 12 up (since 71s), 12 in (since 71s)
 
  data:
    pools:   5 pools, 129 pgs
    objects: 1 objects, 0 B
    usage:   12 GiB used, 588 GiB / 600 GiB avail
    pgs:     129 active+clean
 
0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# 

0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# ceph osd tree
ID  CLASS  WEIGHT   TYPE NAME               STATUS  REWEIGHT  PRI-AFF
-1         0.58557  root default                                     
-3         0.19519      host oc0-compute-0                           
 0    hdd  0.04880          osd.0               up   1.00000  1.00000
 1    hdd  0.04880          osd.1               up   1.00000  1.00000
 2    hdd  0.04880          osd.2               up   1.00000  1.00000
 3    hdd  0.04880          osd.3               up   1.00000  1.00000
-5         0.19519      host oc0-compute-1                           
 4    hdd  0.04880          osd.4               up   1.00000  1.00000
 5    hdd  0.04880          osd.5               up   1.00000  1.00000
 6    hdd  0.04880          osd.6               up   1.00000  1.00000
 7    hdd  0.04880          osd.7               up   1.00000  1.00000
-7         0.19519      host oc0-compute-2                           
 8    hdd  0.04880          osd.8               up   1.00000  1.00000
 9    hdd  0.04880          osd.9               up   1.00000  1.00000
10    hdd  0.04880          osd.10              up   1.00000  1.00000
11    hdd  0.04880          osd.11              up   1.00000  1.00000
0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# 
```

### Glance works

```
(oc0) [CentOS-8.1 - stack@undercloud ~]$     openstack image create cirros --disk-format=raw --container-format=bare < $raw
...
(oc0) [CentOS-8.1 - stack@undercloud ~]$ openstack image list
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| b63d2959-ac32-4904-8583-2ad96d8305e3 | cirros | active |
+--------------------------------------+--------+--------+
(oc0) [CentOS-8.1 - stack@undercloud ~]$ 

0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# rbd -p images ls -l
NAME                                       SIZE    PARENT  FMT  PROT  LOCK
b63d2959-ac32-4904-8583-2ad96d8305e3       44 MiB            2            
b63d2959-ac32-4904-8583-2ad96d8305e3@snap  44 MiB            2  yes       
0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# 
```

### Cinder works

```
(oc0) [CentOS-8.1 - stack@undercloud ~]$ openstack volume create --size 1 test-volume
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| attachments         | []                                   |
| availability_zone   | nova                                 |
| bootable            | false                                |
| consistencygroup_id | None                                 |
| created_at          | 2020-06-01T20:53:15.000000           |
| description         | None                                 |
| encrypted           | False                                |
| id                  | 758d65aa-a6b8-4b24-be4c-17549868b12c |
| migration_status    | None                                 |
| multiattach         | False                                |
| name                | test-volume                          |
| properties          |                                      |
| replication_status  | None                                 |
| size                | 1                                    |
| snapshot_id         | None                                 |
| source_volid        | None                                 |
| status              | creating                             |
| type                | tripleo                              |
| updated_at          | None                                 |
| user_id             | 555ce74bd67c4c18be2515b512220050     |
+---------------------+--------------------------------------+
(oc0) [CentOS-8.1 - stack@undercloud ~]$ openstack volume list
+--------------------------------------+-------------+-----------+------+-------------+
| ID                                   | Name        | Status    | Size | Attached to |
+--------------------------------------+-------------+-----------+------+-------------+
| 758d65aa-a6b8-4b24-be4c-17549868b12c | test-volume | available |    1 |             |
+--------------------------------------+-------------+-----------+------+-------------+
(oc0) [CentOS-8.1 - stack@undercloud ~]$ 

0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# rbd -p volumes ls -l
NAME                                         SIZE   PARENT  FMT  PROT  LOCK
volume-758d65aa-a6b8-4b24-be4c-17549868b12c  1 GiB            2            
0;@oc0-controller-0:/[ceph: root@oc0-controller-0 /]# 

```

## todo

- Until we have https://github.com/ceph/ceph/pull/34879 we're adding
  additional servers and their OSDs via tripleo-ceph roles which call
  ceph orchestrator.
- [tripleo-ceph spec](https://review.opendev.org/#/c/723108)


