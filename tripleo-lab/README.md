# Use tripleo-lab to create an undercloud

I run the following on
[my hypervisor](http://blog.johnlikesopenstack.com/2018/08/pc-for-tripleo-quickstart.html)
which is running centos8.

```
 git clone git@github.com:cjeanner/tripleo-lab.git

 cd tripleo-lab

 cat inventory.yaml.example | sed s/IP_ADDRESS/127.0.0.1/g > inventory.yaml

 cp ~/victoria/tripleo-lab/overrides.yml environments/overrides.yml
 cp ~/victoria/tripleo-lab/roles_validations_tasks_main.yaml roles/validations/tasks/main.yaml

 ansible -i inventory.yaml -m ping builder

 ansible-playbook -i inventory.yaml config-host.yaml

 ansible-playbook --become -i inventory.yaml builder.yaml -e @environments/overrides.yml
```
