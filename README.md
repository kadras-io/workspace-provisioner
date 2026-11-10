# Workspace Provisioner

![Test Workflow](https://github.com/kadras-io/workspace-provisioner/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/workspace-provisioner/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package that provisions namespaces as workspaces for the platform users, such as application developers. Each workspace is configured with the credentials and roles needed to work with the Kadras [Engineering Platform](https://github.com/kadras-io/engineering-platform).

## ✨&nbsp; What's Included

* **Namespaces**. Each namespace in `namespaces` is created, or adopted if it already exists.
* **Credentials**. The OCI registry, Cosign, and Git credentials are shared from a central namespace with all the workspaces, via [secretgen-controller](https://github.com/carvel-dev/secretgen-controller).
* **ServiceAccounts**. A ServiceAccount for the supply chains, with the credentials and the supply chain roles, and one for the GitOps reconciliation.

| Resource | In each workspace |
|----------|-------------------|
| `Namespace` | Always |
| `Secret` `canonical-registry-credentials` | Always, populated when `oci.pull_secret` is set |
| `SecretImport` | When `cosign.secret` or `git.secret` is set |
| `ServiceAccount` and `RoleBinding`s for the supply chains | Always |
| `ServiceAccount` and `RoleBinding` `gitops-reconciler` | Always |

For each credential, a `SecretExport` is created next to its Secret, in the central namespace.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.35+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

### Dependencies

Workspace Provisioner requires [secretgen-controller](https://github.com/carvel-dev/secretgen-controller) to share the credentials with the workspaces. You can install it with the [secretgen-controller](https://github.com/kadras-io/package-for-secretgen-controller) package from the [Kadras package repository](https://github.com/kadras-io/kadras-packages).

The supply chain roles bound in each workspace, `supply-chain-workload` and `supply-chain-deliverable`, are provided by the Kadras [Engineering Platform](https://github.com/kadras-io/engineering-platform), of which Workspace Provisioner is part.

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

```shell
kctrl package repository add -r kadras-packages \
  --url ghcr.io/kadras-io/kadras-packages \
  -n kadras-system --create-namespace
```

<details><summary>Installation without package repository</summary>
The recommended way of installing the Workspace Provisioner package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

```shell
kubectl create namespace kadras-system
kapp deploy -a workspace-provisioner-package -n kadras-system -y \
  -f https://github.com/kadras-io/workspace-provisioner/releases/latest/download/metadata.yml \
  -f https://github.com/kadras-io/workspace-provisioner/releases/latest/download/package.yml
```
</details>

The package provisions the namespaces listed in the values, so create a `values.yml` file first. See [Configuration](#configuration).

```yaml
namespaces:
  - name: dev
```

Install the Workspace Provisioner package:

```shell
kctrl package install -i workspace-provisioner \
  -p workspace-provisioner.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
> ```shell
> kctrl package available list -p workspace-provisioner.packages.kadras.io -n kadras-system
> ```

Verify the installed packages and their status:

```shell
kctrl package installed list -n kadras-system
```

### Try It Out

With secretgen-controller installed, share the OCI registry credentials with a new workspace:

```shell
kubectl create secret docker-registry registry-credentials -n kadras-system \
  --docker-server=ghcr.io \
  --docker-username=${GITHUB_USER} \
  --docker-password=${GITHUB_TOKEN}

cat > values.yml <<EOF
namespaces:
  - name: dev
oci:
  pull_secret:
    name: registry-credentials
    namespace: kadras-system
EOF

kctrl package install -i workspace-provisioner \
  -p workspace-provisioner.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

Check that the credentials are available in the workspace, attached to the supply chain ServiceAccount:

```shell
kubectl get secret canonical-registry-credentials -n dev -o jsonpath='{.data.\.dockerconfigjson}' | base64 --decode
kubectl get serviceaccount supply-chain -n dev -o yaml
```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to the Kadras Engineering Platform, check out [kadras.io](https://kadras.io).

* [Workspaces and permissions](docs/workspaces.md)
* [Credentials](docs/credentials.md)
* [Configuration and ytt overlays](docs/configuration.md)
* [Upgrading and uninstalling](docs/upgrade.md)
* [Verifying the release](docs/verify-release.md)

## 🎯&nbsp; Configuration

The Workspace Provisioner package can be customized via a `values.yml` file.

```yaml
namespaces:
  - name: qa
  - name: staging

oci:
  pull_secret:
    name: supply-chain-registry-credentials
    namespace: kadras-system
```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i workspace-provisioner \
  -p workspace-provisioner.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

The generated resources can be customized beyond the values via ytt overlays. See [configuration.md](docs/configuration.md).

### Values

The Workspace Provisioner package has the following configurable properties.

<details><summary>Configurable properties</summary>

<!-- values-table:start -->

| Config | Default | Description |
|--------|---------|-------------|
| `namespaces` | `[]` | The namespaces to provision and configure as workspaces. |
| `namespaces[].name` | `""` | The name of the namespace. It's created if it doesn't exist. |
| `service_account` | `"supply-chain"` | The ServiceAccount to configure with credentials and roles in each workspace. |
| `oci.pull_secret.name` | `""` | The name of the Secret holding the credentials to pull images from the OCI registry. See docs/credentials.md for the expected format. |
| `oci.pull_secret.namespace` | `""` | The namespace of the Secret holding the credentials to pull images from the OCI registry. |
| `cosign.secret.name` | `""` | The name of the Secret holding the Cosign key pair. See docs/credentials.md for the expected format. |
| `cosign.secret.namespace` | `""` | The namespace of the Secret holding the Cosign key pair. |
| `git.server` | `"https://github.com"` | The Git server hosting the Git repositories used in the GitOps workflows. |
| `git.secret.name` | `""` | The name of the Secret holding the Git credentials. See docs/credentials.md for the expected format. |
| `git.secret.namespace` | `""` | The namespace of the Secret holding the Git credentials. |

<!-- values-table:end -->

</details>

## 🛠️&nbsp; Development

The development environment is defined with [devenv](https://devenv.sh). Enter it with `devenv shell`, or automatically with [direnv](https://direnv.net) after running `direnv allow`. Run `task --list` to see all the available tasks.

```shell
# Run the unit tests, which render the package and check the result without a cluster.
task test:config

# Create a local kind cluster and run the integration tests on it.
task cluster:setup
task test:integration

# Deploy the package from the local sources to the current cluster.
task dev

# Update the table of configurable values in this README after changing the values schema.
task docs:values
```

The unit tests are described in [test/unit/README.md](test/unit/README.md).

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
