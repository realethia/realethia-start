#!/usr/bin/env bash
# Verify tools needed for local Realethia development.

set -euo pipefail
source "$(dirname "$0")/lib.sh"

MISSING=()
OPTIONAL_MISSING=()

check() {
  local cmd="$1"
  local label="${2:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  \033[32mok\033[0m  %s (%s)\n' "$label" "$(command -v "$cmd")"
  else
    printf '  \033[31mmissing\033[0m  %s\n' "$label"
    MISSING+=("$label")
  fi
}

check_optional() {
  local cmd="$1"
  local label="${2:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  \033[32mok\033[0m  %s (%s)\n' "$label" "$(command -v "$cmd")"
  else
    printf '  \033[33moptional\033[0m  %s\n' "$label"
    OPTIONAL_MISSING+=("$label")
  fi
}

log "Checking prerequisites (workspace: ${REALETHIA_WORKSPACE})"
echo ""
echo "Required:"
check git
check docker
check make
check go
check node
check npm

echo ""
echo "Optional:"
if docker compose version >/dev/null 2>&1; then
  printf '  \033[32mok\033[0m  docker compose\n'
else
  printf '  \033[33moptional\033[0m  docker compose\n'
  OPTIONAL_MISSING+=("docker compose")
fi
check_optional yq
check_optional az "Azure CLI"
check_optional azd "Azure Developer CLI"
check_optional kubectl
check_optional expo "Expo CLI (npx expo)"

echo ""
if ((${#MISSING[@]} > 0)); then
  err "Install missing tools before bootstrapping: ${MISSING[*]}"
fi

if ((${#OPTIONAL_MISSING[@]} > 0)); then
  warn "Optional tools not found: ${OPTIONAL_MISSING[*]}"
fi

log "All required prerequisites are installed."
