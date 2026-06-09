#!/usr/bin/env bash
# Shared helpers for realethia-start scripts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Parent directory containing all cloned repos (sibling layout).
# Override: export REALETHIA_WORKSPACE=/path/to/workspace
REALETHIA_WORKSPACE="${REALETHIA_WORKSPACE:-$(cd "${DEV_ROOT}/.." && pwd)}"

REPOS_FILE="${DEV_ROOT}/repos.yaml"

log() { printf '\033[36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!!>\033[0m %s\n' "$*" >&2; }
err() { printf '\033[31mERR>\033[0m %s\n' "$*" >&2; exit 1; }

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || err "Missing required command: ${cmd}"
}

repo_path() {
  local name="$1"
  echo "${REALETHIA_WORKSPACE}/${name}"
}

# Parse repo names from repos.yaml (awk; portable on macOS/Linux).
list_repo_names() {
  awk '/^  - name:/ { print $3 }' "${REPOS_FILE}"
}

repo_url() {
  local name="$1"
  awk -v n="$name" '/^  - name:/ { found=($3==n) } found && /url:/ { print $2; exit }' "${REPOS_FILE}"
}
