# Workspace Provisioner

![Test Workflow](https://github.com/kadras-io/workspace-provisioner/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/workspace-provisioner/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Twitter](https://img.shields.io/static/v1?label=Twitter&message=Follow&color=1DA1F2)](https://twitter.com/kadrasIO)

A Carvel package for provisioning and configuring workspaces (namespaces or virtual clusters) with the necessary credentials, roles and limit ranges to work with the Kadras [Engineering Platform](https://github.com/kadras-io/engineering-platform).

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.30+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

  ```shell
  kapp deploy -a kapp-controller -y \
    -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
  ```

### Dependencies

Workspace Provisioner is used as part of the Kadras [Engineering Platform](https://github.com/kadras-io/engineering-platform) that you can install from the [Kadras package repository](https://github.com/kadras-io/kadras-packages).

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

Install the Workspace Provisioner package:

  ```shell
  kctrl package install -i workspace-provisioner \
    -p workspace-provisioner.packages.kadras.io \
    -v ${VERSION} \
    -n kadras-system
  ```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
>   ```shell
>   kctrl package available list -p workspace-provisioner.packages.kadras.io -n kadras-system
>   ```

Verify the installed packages and their status:

  ```shell
  kctrl package installed list -n kadras-system
  ```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to the Kadras Engineering Platform, check out [kadras.io](https://kadras.io).

## 🎯&nbsp; Configuration

The Workspace Provisioner package can be customized via a `values.yml` file.

  ```yaml
  namespaces:
  - name: qa
  - name: staging

  oci_registry:
    secret:
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

### Values

The Workspace Provisioner package has the following configurable properties.

<details><summary>Configurable properties</summary>

| Config | Default | Description |
|-------|-------------------|-------------|
| `namespaces` | `[]` | Configuration for the namespaces the platform will provision and manage. |
| `service_account` | `supply-chain` | The `ServiceAccount` to be configured with credentials and roles in each workspace. |
| `oci_registry.secret.name` | `""` | The name of the Secret holding the credentials to access the OCI registry. |
| `oci_registry.secret.namespace` | `""` | The namespace of the Secret holding the credentials to access the OCI registry. |
| `cosign.secret.name` | `""` | The name of the Secret holding the Cosign key pair. |
| `cosign.secret.namespace` | `""` | The namespace of the Secret holding the Cosign key pair. |
| `git.server` | `https://github.com` | The Git server hosting the Git repositories used by the platform. |
| `git.secret.name` | `""` | The name of the Secret holding the Git credentials. |
| `git.secret.namespace` | `""` | The namespace of the Secret holding the Git credentials. |

</details>

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.

## 🙏&nbsp; Acknowledgments

This package is inspired by the [namespace setup](https://github.com/vrabbi/tap-oss/tree/main/packages/dev-ns-preperation) package developed by [Scott Rosenberg](https://vrabbi.cloud).
