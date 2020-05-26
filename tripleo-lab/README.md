# Use tripleo-lab to create an undercloud

I run the following on
[my hypervisor](http://blog.johnlikesopenstack.com/2018/08/pc-for-tripleo-quickstart.html)
which is running centos8.

```
 sudo /usr/local/bin/lab-destroy

 git clone git@github.com:cjeanner/tripleo-lab.git

 cd tripleo-lab

 cat inventory.yaml.example | sed s/IP_ADDRESS/127.0.0.1/g > inventory.yaml

 cp ~/victoria/tripleo-lab/overrides.yml environments/overrides.yml
 cp ~/victoria/tripleo-lab/topology-* environments/

 diff -u builder.yaml ~/victoria/tripleo-lab/builder.yaml
 cp ~/victoria/tripleo-lab/builder.yaml builder.yaml

 ansible -i inventory.yaml -m ping builder

 ansible-playbook -i inventory.yaml config-host.yaml

 ansible-playbook -i inventory.yaml builder.yaml -e @environments/overrides.yml -e @environments/topology-standard.yml
```

If the last command is run with the `-t domains -t baremetal -t vbmc` tags, then all of the virtual baremetal servers being provisioned. See [metalsmith](../metalsmith/).
