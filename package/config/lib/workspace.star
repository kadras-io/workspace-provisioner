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

# The names of the namespaces to provision as workspaces.
def workspace_names():
  return [namespace.name for namespace in data.values.namespaces]
end

# ###########
# CREDENTIALS
# ###########

# The name of the placeholder Secret populated by secretgen-controller with the OCI registry credentials.
image_pull_secret_name = "canonical-registry-credentials"

def is_oci_pull_secret_set():
  return is_secret_ref_set(data.values.oci.pull_secret)
end

def is_cosign_secret_set():
  return is_secret_ref_set(data.values.cosign.secret)
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
  if is_cosign_secret_set():
    secrets.append(data.values.cosign.secret)
  end
  if is_git_secret_set():
    secrets.append(data.values.git.secret)
  end
  return secrets
end
