# Unit Tests

The unit tests render the package with ytt and check the result, without a cluster. Run them with `task test:config`.

## Scenarios

Each folder is a scenario:

* `values.yml`: the package values to render with.
* `assert.yaml` (optional): each document must match at least one rendered resource.
* `errors.yaml` (optional): no document may match any rendered resource.

The rendered manifests are also validated with kubeconform against the Kubernetes schemas. The secretgen-controller custom resources have no published schemas, so they're skipped. Finally, `task docs:check` verifies that the README values table matches the values schema.

The documents in `assert.yaml` and `errors.yaml` use the [Chainsaw assertion syntax](https://kyverno.github.io/chainsaw/latest/quick-start/assertion-trees/), the same used by the cluster tests: partial resources, where the fields that are set must match, plus [JMESPath expressions](https://kyverno.github.io/chainsaw/latest/reference/jp/functions/) in parentheses.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
  labels:
    pod-security.kubernetes.io/enforce: restricted
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: workspace-edit
  namespace: dev
(length(subjects)): 2
---
apiVersion: secretgen.carvel.dev/v1alpha1
kind: SecretImport
```

A document is compared with the rendered resources of the same `apiVersion` and `kind`, narrowed down by `metadata.name` and `metadata.namespace` when it sets them. In `errors.yaml`, a document with only `apiVersion` and `kind` means no resource of that kind at all.

The check is done by `hack/assert-render.sh`, which runs `chainsaw assert` on each candidate resource.

## Invalid values

Each file in `invalid` contains values the package must reject, and the expected error in its `# expected:` comment.
