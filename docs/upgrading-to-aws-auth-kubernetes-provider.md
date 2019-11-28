# Upgrading from version <= 7.x to 8.0.0

In version 8.0.0 the way the aws-auth config map in the kube-system namespaces is managed, has been changed.
Before this was managed via kubectl using a null resources. This was changed to be managed by the terraform kubernetes
provider.

To upgrade you have to add the kubernetes provider to the place you are calling the module. You can see examples in
the [examples](../examples) folder.
You also have to delete the aws-auth config map before doing an apply.

**This means you need to the apply with the same user/role that created the cluster.**

Since this user will be the only one with admin on the k8s cluster. After that the resource is managed trough the
terraform kubernetes provider.