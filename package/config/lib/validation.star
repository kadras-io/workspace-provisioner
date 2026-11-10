load("@ytt:regexp", "regexp")

# Validation helpers used by the values schema, and by the templates to interpret the values they validate.
# They must not depend on data values, since they run while the schema is evaluated.

_dns_label = "[a-z0-9]([-a-z0-9]*[a-z0-9])?"

def is_dns_label(value):
  return len(value) <= 63 and regexp.match("^" + _dns_label + "$", value)
end

def is_dns_subdomain(value):
  return len(value) <= 253 and regexp.match("^" + _dns_label + "(\\." + _dns_label + ")*$", value)
end

# An HTTP or HTTPS URL, like `https://github.com`.
def is_http_url(value):
  return regexp.match("^https?://[^\\s/]+(/\\S*)?$", value)
end

# A reference to a Secret in another namespace, with both `name` and `namespace` set, or neither.
def is_secret_ref_complete(ref):
  return (ref["name"] == "") == (ref["namespace"] == "")
end

def is_secret_ref_set(ref):
  return ref["name"] != "" and ref["namespace"] != ""
end
