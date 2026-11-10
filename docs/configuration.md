# Configuration

The package values cover the decisions most installations need to make: the workspaces to provision, their access and Pod Security Standard, and the credentials to share with them. Everything else can be customized via ytt overlays applied to the generated resources.

## ytt overlays

kapp-controller applies the [ytt overlays](https://carvel.dev/ytt/docs/latest/ytt-overlays/) stored in a Secret on top of the package configuration, when the PackageInstall references it with the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.<n>` annotation. See [PackageInstall](https://carvel.dev/kapp-controller/docs/latest/package-install-extensions/).

For example, to add a label to all the workspace namespaces, like the one selecting them for a Kyverno policy:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: workspace-provisioner-overlays
  namespace: kadras-system
stringData:
  namespaces.yml: |
    #@ load("@ytt:overlay", "overlay")
    #@overlay/match by=overlay.subset({"kind":"Namespace"}), expects="0+"
    ---
    metadata:
      labels:
        #@overlay/match missing_ok=True
        platform.kadras.io/tier: production
```

Reference the Secret from the PackageInstall:

```shell
kubectl annotate packageinstall workspace-provisioner -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=workspace-provisioner-overlays
```

All the generated resources have the `app.kubernetes.io/component: workspace-provisioner` label. See [workspaces.md](workspaces.md) and [credentials.md](credentials.md) for the resources generated in each workspace.
