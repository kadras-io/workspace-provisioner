# Upgrading

Upgrade the package with the new version, and the same values file.

```shell
kctrl package installed update -i workspace-provisioner -v ${VERSION} -n kadras-system --values-file values.yml
```

## Uninstalling

```shell
kctrl package installed delete -i workspace-provisioner -n kadras-system
```

> **Warning**
> Uninstalling the package deletes all the workspace namespaces, including the workloads running in them.

The same happens to a single workspace when its namespace is removed from `namespaces`.

The namespaces that existed before the package was installed are adopted, and deleted as well.
