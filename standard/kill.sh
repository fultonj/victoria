#!/bin/bash

openstack overcloud delete overcloud --yes

openstack overcloud node unprovision --yes --all \
  --stack overcloud \
  ../metalsmith/standard-small.yaml
