# Credentials

The credentials are stored once, in a central namespace like `kadras-system`, and shared with all the workspaces via [secretgen-controller](https://github.com/carvel-dev/secretgen-controller). For each credential, the package creates a `SecretExport` next to the Secret, allowing the workspaces to import it.

Each credential is referenced by the `name` and `namespace` of its Secret. Both must be set, or neither. A credential that isn't set is not shared.

Updating a Secret in the central namespace updates it in all the workspaces.

## OCI registry

Set `oci.pull_secret` to share the credentials to pull images from the OCI registry.

```yaml
oci:
  pull_secret:
    name: registry-credentials
    namespace: kadras-system
```

The Secret is of type `kubernetes.io/dockerconfigjson`.

```shell
kubectl create secret docker-registry registry-credentials -n kadras-system \
  --docker-server=ghcr.io \
  --docker-username=${GITHUB_USER} \
  --docker-password=${GITHUB_TOKEN}
```

In each workspace, secretgen-controller merges the credentials into the `canonical-registry-credentials` placeholder Secret, which is the image pull secret of the `default` ServiceAccount: the workloads that don't set another ServiceAccount, like Knative Services, pull their images with it. See [image pull secrets](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/secret-export.md#using-placeholder-secrets). Without `oci.pull_secret`, the placeholder Secret stays empty.

## Git

Set `git.secret` to share the credentials to access the Git repositories used in the GitOps workflows.

```yaml
git:
  secret:
    name: git-credentials
    namespace: kadras-system
```

The Secret holds the `username` and `password` keys.

```shell
kubectl create secret generic git-credentials -n kadras-system \
  --from-literal=username=git \
  --from-literal=password=${GITHUB_TOKEN}
```

In each workspace, a `SecretImport` imports the credentials into a Secret with the same name, which the Flux sources reference for HTTPS authentication. See [GitRepository](https://fluxcd.io/flux/components/source/gitrepositories/#secret-reference).

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: my-app
  namespace: dev
spec:
  interval: 5m
  url: https://github.com/example/my-app
  ref:
    branch: main
  secretRef:
    name: git-credentials
```
