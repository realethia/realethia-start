#!/usr/bin/env bash
# Prepare cloned repos for local development.

set -euo pipefail
source "$(dirname "$0")/lib.sh"

ONLY=""
SKIP_ETHIA_BUILD=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [repo...]

Run bootstrap steps for local-dev repos (see repos.yaml).
If repo names are given, only those repos are bootstrapped.

Options:
  --skip-ethia-build    Only copy .env; do not run make build-start
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-ethia-build) SKIP_ETHIA_BUILD=1; shift ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*) err "Unknown option: $1" ;;
    *) break ;;
  esac
done

TARGETS=("$@")
if ((${#TARGETS[@]} == 0)); then
  TARGETS=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && TARGETS+=("$line")
  done < <(list_local_dev_repo_names)
fi

"${SCRIPT_DIR}/check-prereqs.sh"

for name in "${TARGETS[@]}"; do
  dest="$(repo_path "$name")"
  [[ -d "${dest}/.git" ]] || err "Repo not cloned: ${name} (run: make clone)"

  log "Bootstrap ${name}..."
  case "$name" in
    ethia)
      if [[ ! -f "${dest}/infra/.env" ]]; then
        cp "${dest}/infra/.env.example" "${dest}/infra/.env"
        warn "Created ethia/infra/.env — fill secrets (POSTGRES_PASSWORD, OPENAI_API_KEY, Azure storage, etc.)"
      fi
      if [[ "${SKIP_ETHIA_BUILD}" == "1" ]]; then
        log "Skipped ethia build (SKIP_ETHIA_BUILD)"
      else
        log "Building and starting Ethia stack (this may take several minutes)..."
        (cd "${dest}" && make build-start)
        log "Register Debezium connector (one-time after first start)..."
        (cd "${dest}" && make debezium-register) || warn "debezium-register failed — run manually when stack is healthy"
      fi
      ;;
    realethia-dashboard)
      (cd "${dest}" && npm ci && npm run codegen:types)
      ;;
    realethia-app)
      (cd "${dest}" && npm ci)
      ;;
    *)
      warn "No bootstrap steps defined for: ${name}"
      ;;
  esac
  log "Done: ${name}"
done

log "Bootstrap complete."
echo ""
echo "Next steps:"
echo "  make dev-dashboard   # mock API + Next.js on :3001 / :4000"
echo "  make dev-ethia       # Ethia console on :8080 (if not already running)"
echo "  make dev-app         # Expo dev server"
