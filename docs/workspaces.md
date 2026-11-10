# Workspaces

Workspace Provisioner configures each namespace in `namespaces` as a workspace, ready to run the Kadras supply chains and GitOps workflows.

```yaml
namespaces:
  - name: dev
  - name: prod
```

## Namespaces

Each namespace is created if it doesn't exist. An existing namespace is adopted rather than recreated, and so are the resources the package creates in it, if they already exist. See [create strategies](https://carvel.dev/kapp/docs/latest/apply/#kappk14siocreate-strategy).

Removing a namespace from `namespaces` deletes it, with everything it contains. See [upgrade.md](upgrade.md).

## Permissions

Each workspace contains two ServiceAccounts.

### Supply chains

The supply chains run with the ServiceAccount in `service_account`, `supply-chain` by default. It's configured with:

* the credentials to pull images from the OCI registry, as image pull secret;
* the Cosign key pair and the Git credentials, when configured. See [credentials.md](credentials.md);
* the `supply-chain-workload` and `supply-chain-deliverable` ClusterRoles, bound in the workspace. They're provided by the Kadras [Engineering Platform](https://github.com/kadras-io/engineering-platform).

```yaml
namespaces:
  - name: dev
service_account: builder
```

### GitOps

The GitOps tools, such as the [GitOps Configurer](https://github.com/kadras-io/gitops-configurer), deploy the workloads in the workspace with the `gitops-reconciler` ServiceAccount. It's bound to the `cluster-admin` ClusterRole in the workspace, so it can manage any resource within it, but nothing outside.
