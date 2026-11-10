# Renders the package values schema (OpenAPI v3) as a Markdown table, one row per leaf property.
def rows(prefix):
  .properties // {} | to_entries[] |
  (prefix + .key) as $path |
  if .value.type == "object" and (.value.properties // {} | length) > 0 then
    .value | rows($path + ".")
  elif .value.type == "array" and (.value.items.properties // {} | length) > 0 then
    "| `\($path)` | `\(.value.default | tojson)` | \(.value.description // "" | gsub("\n"; " ")) |",
    (.value.items | rows($path + "[]."))
  else
    "| `\($path)` | `\(.value.default | if type == "string" then "\"" + . + "\"" else tojson end)` | \(.value.description // "" | gsub("\n"; " ")) |"
  end;

"| Config | Default | Description |",
"|--------|---------|-------------|",
(.components.schemas.dataValues | rows(""))
