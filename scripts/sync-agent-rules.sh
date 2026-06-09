#!/usr/bin/env bash
# Copy shared Cursor agent rules from realethia-start to sibling repos.

set -euo pipefail
source "$(dirname "$0")/lib.sh"

RULES_SRC="${DEV_ROOT}/.cursor/rules"
RULES=("git-commits.mdc")

for rule in "${RULES[@]}"; do
  [[ -f "${RULES_SRC}/${rule}" ]] || err "Missing rule: ${RULES_SRC}/${rule}"
done

for name in $(list_repo_names); do
  [[ "$name" == "realethia-start" ]] && continue
  dest="$(repo_path "$name")"
  [[ -d "${dest}/.git" ]] || continue

  mkdir -p "${dest}/.cursor/rules"
  for rule in "${RULES[@]}"; do
    cp "${RULES_SRC}/${rule}" "${dest}/.cursor/rules/${rule}"
    log "Synced ${rule} → ${name}/.cursor/rules/"
  done
done

log "Agent rules synced."
