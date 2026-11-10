# Upgrading

Upgrade the package with the new version, and the same values file.

```shell
kctrl package installed update -i workspace-provisioner -v ${VERSION} -n kadras-system --values-file values.yml
```

## Uninstalling

```shell
kctrl package installed delete -i workspace-provisioner -n kadras-system
```

Uninstalling the package keeps the workspace namespaces, with the workloads running in them and their `default` ServiceAccounts. It deletes the `gitops-reconciler` ServiceAccount, the RoleBindings of the members, the imported credentials, and the SecretExports in the central namespace. The shared credentials themselves are kept.

The same happens to a single workspace when its namespace is removed from `namespaces`. To delete a workspace with everything in it, delete its namespace explicitly.

```shell
kubectl delete namespace dev
```
