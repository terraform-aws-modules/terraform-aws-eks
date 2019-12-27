Node groups wip
===============

To be decided
-------------

### How to support mutiple node_groups?
Have user use module multiple times in TF project.

### How to enforce uniqueness of node group name?
Don't. Let resulting AWS/Terraform error inidicate the requirement of node groups names needing to be unique. 
There will be references to created resources anyway via the module outputs.
Letting user chose unique ng name seems reasonable, similar to how a unique name for the cluster itself should be chosen.

TBD: Prefix with cluster name? (needed or not?)

### How to preserve ability to manage aws-auth?
Core module manages `aws-auth`. Now a separate module creates the node groups.

Initial plan: Create role for node groups in core module, unless opted-out. Use core module output role name/arn (whatever's suitable) in submodule.

Note that in current master, a role created for workers groups or node groups, seems to be used by all node groups. So creating that single role in core module seams feasible as it's not dependent on the umber of node groups added.

### Defaults
If needing to define multiple node_groups having a lot of similarities, there will be a lot of repetition.

Consider providing a map having defaults, allowing the same map to be passed to multiple node group modules.

### Documentation

Besides examples there should be documentation (can be README).
