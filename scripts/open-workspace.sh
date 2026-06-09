#!/usr/bin/env bash
# Open the Realethia multi-root workspace and README.
# Editor order: Cursor, then VS Code (override with REALETHIA_EDITOR=code).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORKSPACE_FILE="${DEV_ROOT}/realethia.code-workspace"
README="${DEV_ROOT}/README.md"

REALETHIA_EDITOR="${REALETHIA_EDITOR:-cursor}"

[[ -f "${WORKSPACE_FILE}" ]] || { echo "Missing workspace file: ${WORKSPACE_FILE}" >&2; exit 1; }
[[ -f "${README}" ]] || { echo "Missing README: ${README}" >&2; exit 1; }

log() { printf '\033[36m==>\033[0m %s\n' "$*"; }

find_cursor_cli() {
  if command -v cursor >/dev/null 2>&1; then
    command -v cursor
    return 0
  fi
  local app_cursor="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
  if [[ -x "${app_cursor}" ]]; then
    echo "${app_cursor}"
    return 0
  fi
  return 1
}

find_vscode_cli() {
  if command -v code >/dev/null 2>&1; then
    command -v code
    return 0
  fi
  local app_code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  if [[ -x "${app_code}" ]]; then
    echo "${app_code}"
    return 0
  fi
  return 1
}

open_with_cli() {
  local editor_cmd="$1"
  local editor_name="$2"
  log "Opening in ${editor_name}..."
  "${editor_cmd}" -r "${WORKSPACE_FILE}" "${README}" 2>/dev/null \
    || { "${editor_cmd}" "${WORKSPACE_FILE}"; "${editor_cmd}" -r "${README}" 2>/dev/null || "${editor_cmd}" "${README}"; }
}

open_with_macos_app() {
  local app_name="$1"
  local editor_name="$2"
  [[ "$(uname -s)" == Darwin ]] || return 1
  [[ -d "/Applications/${app_name}.app" ]] || return 1
  log "Opening in ${editor_name}..."
  open -a "${app_name}" "${WORKSPACE_FILE}"
  open -a "${app_name}" "${README}"
}

try_cursor() {
  if EDITOR_CMD="$(find_cursor_cli)"; then
    open_with_cli "${EDITOR_CMD}" "Cursor"
    return 0
  fi
  open_with_macos_app "Cursor" "Cursor"
}

try_vscode() {
  if EDITOR_CMD="$(find_vscode_cli)"; then
    open_with_cli "${EDITOR_CMD}" "VS Code"
    return 0
  fi
  open_with_macos_app "Visual Studio Code" "VS Code"
}

opened=0
if [[ "${REALETHIA_EDITOR}" == code ]]; then
  try_vscode && opened=1
  [[ "${opened}" == 1 ]] || try_cursor && opened=1
else
  try_cursor && opened=1
  [[ "${opened}" == 1 ]] || try_vscode && opened=1
fi

if [[ "${opened}" != 1 ]]; then
  echo "No editor found. Install Cursor (preferred) or VS Code." >&2
  echo "  Cursor:  Cursor → Shell Command: Install 'cursor' command in PATH" >&2
  echo "  VS Code: VS Code → Shell Command: Install 'code' command in PATH" >&2
  echo "Workspace: ${WORKSPACE_FILE}" >&2
  echo "README:    ${README}" >&2
  exit 1
fi

log "Opened workspace and README."
