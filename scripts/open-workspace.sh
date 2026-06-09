#!/usr/bin/env bash
# Open the Realethia multi-root workspace and README in Cursor (or VS Code).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_FILE="${DEV_ROOT}/realethia.code-workspace"
README="${DEV_ROOT}/README.md"

[[ -f "${WORKSPACE_FILE}" ]] || { echo "Missing workspace file: ${WORKSPACE_FILE}" >&2; exit 1; }
[[ -f "${README}" ]] || { echo "Missing README: ${README}" >&2; exit 1; }

log() { printf '\033[36m==>\033[0m %s\n' "$*"; }

if command -v cursor >/dev/null 2>&1; then
  cursor -r "${WORKSPACE_FILE}" "${README}" 2>/dev/null \
    || { cursor "${WORKSPACE_FILE}"; cursor -r "${README}" 2>/dev/null || cursor "${README}"; }
elif command -v code >/dev/null 2>&1; then
  code -r "${WORKSPACE_FILE}" "${README}" 2>/dev/null \
    || { code "${WORKSPACE_FILE}"; code -r "${README}" 2>/dev/null || code "${README}"; }
else
  echo "Cursor CLI not found. Install Cursor and enable the 'cursor' shell command."
  echo "Workspace: ${WORKSPACE_FILE}"
  echo "README:    ${README}"
  exit 1
fi

log "Opened workspace and README."
