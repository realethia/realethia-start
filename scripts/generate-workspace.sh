#!/usr/bin/env bash
# Regenerate realethia.code-workspace from repos.yaml.

set -euo pipefail
source "$(dirname "$0")/lib.sh"

OUT="${DEV_ROOT}/realethia.code-workspace"

{
  echo '{'
  echo '  "folders": ['
  first=1
  for name in realethia-start $(list_repo_names); do
    [[ "$name" == "realethia-start" ]] && rel="." || rel="../${name}"
    if [[ "${first}" == "1" ]]; then first=0; else echo ','; fi
    printf '    {\n      "name": "%s",\n      "path": "%s"\n    }' "$name" "$rel"
  done
  echo ''
  echo '  ],'
  cat <<'SETTINGS'
  "settings": {
    "yaml.validate": false,
    "yaml.hover": true,
    "yaml.completion": true,
    "files.associations": {
      "**/api-spec/**/*.yaml": "yaml",
      "**/api-spec/**/*.yml": "yaml"
    },
    "yaml.schemaStore.enable": false,
    "tailwindCSS.includeLanguages": {
      "css": "css",
      "postcss": "css"
    }
  }
SETTINGS
  echo '}'
} >"${OUT}"

log "Wrote ${OUT}"
