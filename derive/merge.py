# make simple_args.json into args.json using mock data
import json
import yaml

with open('molecule/mock_params') as f:
    tripleo_get_flatten_params = yaml.safe_load(f)

with open('molecule/mock_baremetal_ComputeHCI') as f:
    hw_data = yaml.safe_load(f)

with open('simple_args.json') as f:
    args = json.load(f)

# tripleo_get_flatten_params.stack_data.heat_resource_tree
tripleo_heat_resource_tree = tripleo_get_flatten_params['stack_data']['heat_resource_tree']

args["ANSIBLE_MODULE_ARGS"]["introspection_data"] = hw_data
args["ANSIBLE_MODULE_ARGS"]["tripleo_heat_resource_tree"] = tripleo_heat_resource_tree

with open('args2.json', 'w') as json_file:
    json.dump(args, json_file, indent = 4, sort_keys=True)
