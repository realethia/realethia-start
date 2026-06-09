#!/usr/bin/env bash
# Clone all Realethia system repositories into the workspace.

set -euo pipefail
source "$(dirname "$0")/lib.sh"

BRANCH="${BRANCH:-main}"
SKIP_EXISTING="${SKIP_EXISTING:-1}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Clone all repos from repos.yaml into: ${REALETHIA_WORKSPACE}

Options:
  -b, --branch BRANCH   Branch to checkout (default: main)
  -f, --force           Re-clone if directory exists but is not a git repo
  -h, --help            Show this help

Environment:
  REALETHIA_WORKSPACE   Target directory for clones (default: parent of realethia-start)
  SKIP_EXISTING=0       Re-fetch and checkout even when repo already exists
EOF
}

FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -b | --branch)
      BRANCH="$2"
      shift 2
      ;;
    -f | --force) FORCE=1; shift ;;
    -h | --help)
      usage
      exit 0
      ;;
    *) err "Unknown option: $1" ;;
  esac
done

require_cmd git

mkdir -p "${REALETHIA_WORKSPACE}"
log "Workspace: ${REALETHIA_WORKSPACE}"
log "Branch: ${BRANCH}"

for name in $(list_repo_names); do
  dest="$(repo_path "$name")"
  url="$(repo_url "$name")"

  if [[ "$name" == "realethia-start" ]]; then
    continue
  fi

  if [[ -d "${dest}/.git" ]]; then
    if [[ "${SKIP_EXISTING}" == "1" ]]; then
      log "Skip ${name} (already cloned at ${dest})"
      continue
    fi
    log "Update ${name}..."
    git -C "${dest}" fetch origin
    git -C "${dest}" checkout "${BRANCH}" 2>/dev/null || git -C "${dest}" checkout -B "${BRANCH}" "origin/${BRANCH}"
    git -C "${dest}" pull --ff-only origin "${BRANCH}" 2>/dev/null || true
    continue
  fi

  if [[ -e "${dest}" && "${FORCE}" != "1" ]]; then
    warn "Path exists but is not a git repo: ${dest} (use -f to overwrite after manual cleanup)"
    continue
  fi

  log "Clone ${name}..."
  git clone --branch "${BRANCH}" "${url}" "${dest}" 2>/dev/null \
    || git clone "${url}" "${dest}"
  if ! git -C "${dest}" rev-parse --verify "${BRANCH}" >/dev/null 2>&1; then
    git -C "${dest}" checkout -b "${BRANCH}" "origin/${BRANCH}" 2>/dev/null \
      || git -C "${dest}" checkout "${BRANCH}" 2>/dev/null \
      || warn "Could not checkout branch ${BRANCH} for ${name}"
  fi
done

log "Done. Open workspace: make workspace-open"
