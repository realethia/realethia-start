#!/usr/bin/env bash
# Clone realethia-start into a workspace folder, run setup, open Cursor with README.
#
# Run from the folder that should contain all Realethia repos:
#
#   cd ~/work/realethia
#   curl -fsSL https://raw.githubusercontent.com/realethia/realethia-start/main/scripts/install.sh | bash
#
# Or with a local copy:
#
#   ./realethia-start/scripts/install.sh
#   ./realethia-start/scripts/install.sh /path/to/workspace

set -euo pipefail

REPO_NAME="realethia-start"
REPO_URL="https://github.com/realethia/realethia-start.git"
BRANCH="${BRANCH:-main}"

log() { printf '\033[36m==>\033[0m %s\n' "$*"; }
err() { printf '\033[31mERR>\033[0m %s\n' "$*" >&2; exit 1; }

resolve_workspace() {
  local arg="${1:-}"
  if [[ -n "${arg}" ]]; then
    cd "${arg}" && pwd
    return
  fi
  if [[ "$(basename "$(pwd)")" == "${REPO_NAME}" && -f Makefile ]]; then
    cd .. && pwd
    return
  fi
  pwd
}

WORKSPACE="$(resolve_workspace "${1:-}")"
START_DIR="${WORKSPACE}/${REPO_NAME}"

command -v git >/dev/null 2>&1 || err "git is required"
command -v make >/dev/null 2>&1 || err "make is required"

log "Workspace: ${WORKSPACE}"
mkdir -p "${WORKSPACE}"

if [[ -d "${START_DIR}/.git" ]]; then
  log "Using existing ${REPO_NAME} at ${START_DIR}"
else
  log "Cloning ${REPO_NAME}..."
  git clone --branch "${BRANCH}" "${REPO_URL}" "${START_DIR}" 2>/dev/null \
    || git clone "${REPO_URL}" "${START_DIR}"
fi

export REALETHIA_WORKSPACE="${WORKSPACE}"
cd "${START_DIR}"

log "Running setup (clone sibling repos, prepare deps and env)..."
make setup

log "Opening Cursor..."
bash "${START_DIR}/scripts/open-workspace.sh"

log "Done."
