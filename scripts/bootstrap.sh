#!/usr/bin/env bash
# Prepare cloned repos: dependencies and env files only (does not start services).

set -euo pipefail
source "$(dirname "$0")/lib.sh"

usage() {
  cat <<EOF
Usage: $(basename "$0") [repo...]

Prepare repos for local development (see repos.yaml):
  - copy .env files from examples
  - install npm dependencies
  - run codegen where needed

Does not build, start, or deploy anything. Use: make start

If repo names are given, only those repos are prepared.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TARGETS=("$@")
if ((${#TARGETS[@]} == 0)); then
  TARGETS=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && TARGETS+=("$line")
  done < <(list_repo_names)
fi

"${SCRIPT_DIR}/check-prereqs.sh"

copy_env_if_missing() {
  local example="$1"
  local dest="$2"
  local label="$3"
  if [[ -f "${example}" && ! -f "${dest}" ]]; then
    cp "${example}" "${dest}"
    warn "Created ${label} — review and fill in secrets"
  fi
}

for name in "${TARGETS[@]}"; do
  dest="$(repo_path "$name")"
  [[ -d "${dest}/.git" ]] || err "Repo not cloned: ${name} (run: make clone)"

  log "Prepare ${name}..."
  case "$name" in
    ethia)
      copy_env_if_missing \
        "${dest}/infra/.env.example" \
        "${dest}/infra/.env" \
        "ethia/infra/.env"
      ;;
    realethia-dashboard)
      (cd "${dest}" && npm ci && npm run codegen:types)
      ;;
    realethia-app)
      (cd "${dest}" && npm ci)
      ;;
    realethia-infra)
      copy_env_if_missing \
        "${dest}/envs/staging/.env.example" \
        "${dest}/envs/staging/.env.staging" \
        "realethia-infra/envs/staging/.env.staging"
      copy_env_if_missing \
        "${dest}/envs/prod/.env.example" \
        "${dest}/envs/prod/.env.prod" \
        "realethia-infra/envs/prod/.env.prod"
      ;;
    realethia-research-docs)
      log "No prepare steps for ${name}"
      ;;
    realethia-start)
      log "Skipped bootstrap repo"
      ;;
    *)
      warn "No prepare steps defined for: ${name}"
      ;;
  esac
  log "Done: ${name}"
done

log "Prepare complete."
"${SCRIPT_DIR}/sync-agent-rules.sh"
echo ""
echo "Next: make start          # build and start local services (Ethia stack)"
echo "      make dev-dashboard  # mock API + Next.js"
echo "      make dev-app        # Expo dev server"
