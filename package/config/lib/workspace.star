load("@ytt:data", "data")
load("/lib/validation.star", "is_secret_ref_set")

# The labels set on all the workspace resources.
def labels():
  return {"app.kubernetes.io/component": "workspace-provisioner"}
end

# The annotations set on the resources that might already exist in the workspace, so that kapp adopts them.
def adopt_annotations():
  return {"kapp.k14s.io/create-strategy": "fallback-on-update"}
end

# The annotations set on the resources that outlive the workspace: kapp adopts them, and never deletes them.
def keep_annotations():
  return dict(adopt_annotations(), **{"kapp.k14s.io/delete-strategy": "orphan"})
end

# The names of the namespaces to provision as workspaces.
def workspace_names():
  return [namespace.name for namespace in data.values.namespaces]
end

# ###########
# SECURITY
# ###########

# The Pod Security Admission labels of a workspace. The `restricted` standard is always audited and warned about,
# so that violations are visible even when a less strict standard is enforced.
def pod_security_labels(namespace):
  level = namespace.pod_security or data.values.pod_security.level
  return {
    "pod-security.kubernetes.io/enforce": level,
    "pod-security.kubernetes.io/audit": "restricted",
    "pod-security.kubernetes.io/warn": "restricted",
  }
end

# The members of a workspace, grouped by the role bound to them.
def members_by_role(namespace):
  roles = {}
  for member in namespace.members:
    roles.setdefault(member.role, []).append(member)
  end
  return roles
end

# ###########
# CREDENTIALS
# ###########

# The name of the placeholder Secret populated by secretgen-controller with the OCI registry credentials.
image_pull_secret_name = "canonical-registry-credentials"

def is_oci_pull_secret_set():
  return is_secret_ref_set(data.values.oci.pull_secret)
end

def is_git_secret_set():
  return is_secret_ref_set(data.values.git.secret)
end

# The Secrets in other namespaces to share with the workspaces, as `secretgen.carvel.dev` references.
def shared_secrets():
  secrets = []
  if is_oci_pull_secret_set():
    secrets.append(data.values.oci.pull_secret)
  end
  if is_git_secret_set():
    secrets.append(data.values.git.secret)
  end
  return secrets
end
