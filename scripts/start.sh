#!/usr/bin/env bash
# Build and start local development services.

set -euo pipefail
source "$(dirname "$0")/lib.sh"

TARGET="${1:-ethia}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [target]

Start local development services. Default target: ethia

Targets:
  ethia       Build and start Ethia Docker Compose stack (+ Debezium register)
  all         Print commands to start the full local stack

Examples:
  make start
  make start TARGET=dashboard
EOF
}

if [[ "${TARGET}" == "-h" || "${TARGET}" == "--help" ]]; then
  usage
  exit 0
fi

require_cmd docker
if ! docker compose version >/dev/null 2>&1; then
  err "docker compose is required to start Ethia"
fi

case "${TARGET}" in
  ethia)
    dest="$(repo_path ethia)"
    [[ -d "${dest}/.git" ]] || err "Repo not cloned: ethia (run: make setup)"
    [[ -f "${dest}/infra/.env" ]] || err "Missing ethia/infra/.env (run: make bootstrap)"

    log "Building and starting Ethia stack (this may take several minutes)..."
    (cd "${dest}" && make build-start)

    log "Register Debezium connector (once after first healthy start)..."
    (cd "${dest}" && make debezium-register) \
      || warn "debezium-register failed — run manually when stack is healthy"

    log "Ethia running."
    echo "  Console:   http://localhost:8080"
    echo "  Postgres:  localhost:5432"
    ;;
  all)
    echo "# Run each in a separate terminal:"
    echo ""
    echo "make start"
    echo "cd $(repo_path realethia-dashboard) && npm run mock"
    echo "cd $(repo_path realethia-dashboard) && npm run dev"
    echo "cd $(repo_path realethia-app) && npx expo start"
    ;;
  dashboard | app)
    err "Use: make dev-${TARGET}"
    ;;
  *)
    err "Unknown target: ${TARGET} (try: ethia, all)"
    ;;
esac
