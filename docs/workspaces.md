# Workspaces

Workspace Provisioner configures each namespace in `namespaces` as a workspace, where the platform users deploy their workloads, directly or via GitOps.

```yaml
namespaces:
  - name: dev
  - name: prod
```

## Namespaces

Each namespace is created if it doesn't exist. An existing namespace is adopted rather than recreated, and so are the resources the package creates in it, if they already exist. See [create strategies](https://carvel.dev/kapp/docs/latest/apply/#kappk14siocreate-strategy).

Removing a namespace from `namespaces`, or uninstalling the package, keeps the namespace and the workloads running in it. Only the access configuration and the credentials are removed. See [upgrade.md](upgrade.md).

## Pod Security

The `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/) is enforced on each workspace, via the [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/) labels of the namespace: Pods must run as non-root, without privilege escalation, with all the capabilities dropped and the `RuntimeDefault` seccomp profile. Pods violating it are rejected.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: my-app
          image: ghcr.io/example/my-app
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
```

The standard can be relaxed for all the workspaces, or for a single one. The violations of the `restricted` standard are always reported as warnings to the users, and in the audit log.

```yaml
namespaces:
  - name: dev
  - name: legacy
    pod_security: privileged
pod_security:
  level: baseline
```

## Access

The access to each workspace is granted via the Kubernetes [default roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles), bound in the namespace. The platform packages extend them with the permissions on their resources, like Knative Services and Flux Kustomizations.

| Role | Permissions in the workspace |
|------|------------------------------|
| `admin` | Manage the workloads, and the access to the workspace via Roles and RoleBindings. |
| `edit` | Manage the workloads. |
| `view` | Read the workloads, except Secrets. |

### Members

The users and groups authenticated by the Kubernetes API server, for example via an OIDC identity provider, are granted access to a workspace as its `members`. For each role, the package creates a `workspace-<role>` RoleBinding. Members are groups with the `edit` role by default.

```yaml
namespaces:
  - name: team-a
    members:
      - name: team-a-developers
      - kind: Group
        name: team-a-leads
        role: admin
      - kind: User
        name: jane@example.com
        role: view
```

### GitOps

The GitOps tools deploy the workloads in the workspace with the `gitops-reconciler` ServiceAccount, bound to the `admin` role. It can manage the workloads and the access to the workspace, but nothing outside. For example, a Flux Kustomization in the workspace uses it via `spec.serviceAccountName`.

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: my-app
  namespace: dev
spec:
  serviceAccountName: gitops-reconciler
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: my-app
  path: ./deploy
  prune: true
```
