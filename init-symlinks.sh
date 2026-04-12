#!/usr/bin/env bash
# init-symlinks.sh — Recreate cloud-storage symlinks for a publication-library instance.
#
# All PDFs, indexed output, and findings are stored in a cloud-synced directory
# (Dropbox, iCloud, Google Drive, etc.) and linked into the project directory.
# Run this script after cloning or on a new machine to restore those links.
#
# Name:         init-symlinks.sh
# Description:  Recreate cloud-storage symlinks for a publication-library instance
# Author:       Alister Lewis-Bowen <alister@lewis-bowen.org>
# Usage:        ./init-symlinks.sh
# Dependencies: bash 4+, lib/pfb submodule (or pfb on PATH)
# Exit codes:   0 success, 1 error
#
# Configuration (via .env or environment):
#   LIBRARY_BASE  Absolute path to the root of your cloud-synced library storage.
#                 See .env.template for examples.
#
# LINKS format: "local_path:cloud_target"
#   Edit the LINKS array below to match your instance's collection layout.
#   - findings         → flat directory in cloud storage
#   - COLLECTION/pdfs  → per-collection PDF directory in cloud storage
#   - COLLECTION/indexed → per-collection indexed output under library-indexed/

set -euo pipefail

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Source .env if present (allows LIBRARY_BASE to be set there)
if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/.env"
fi

# Load pfb for terminal output
PFB_SCRIPT="${SCRIPT_DIR}/lib/pfb/pfb.sh"
if [[ -f "${PFB_SCRIPT}" ]]; then
    # shellcheck source=lib/pfb/pfb.sh
    source "${PFB_SCRIPT}"
elif command -v pfb &>/dev/null; then
    : # pfb already on PATH
else
    echo "ERROR: pfb not found. Run: git submodule update --init lib/pfb" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Validate required configuration
# ---------------------------------------------------------------------------

if [[ -z "${LIBRARY_BASE:-}" ]]; then
    pfb error "LIBRARY_BASE is not set."
    echo
    pfb subheading "Set it in .env (copy .env.template) or export it before running:"
    pfb subheading "  export LIBRARY_BASE=\"/path/to/your/cloud/library\""
    exit 1
fi

# ---------------------------------------------------------------------------
# Symlink definitions — edit to match your instance layout
# ---------------------------------------------------------------------------
# Format: "local_path:cloud_target"
# local_path  — path relative to this script (e.g. findings, collections/NAME/pdfs)
# cloud_target — absolute path under LIBRARY_BASE
#
# Example entries (uncomment and adapt):
#
#   "findings:${LIBRARY_BASE}/library-findings"
#   "collections/my-collection/pdfs:${LIBRARY_BASE}/my-collection"
#   "collections/my-collection/indexed:${LIBRARY_BASE}/library-indexed/my-collection"

declare -a LINKS=(
    # Add your symlink entries here. Example:
    # "findings:${LIBRARY_BASE}/library-findings"
)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

pfb heading "Recreating cloud-storage symlinks" "🔗"
pfb subheading "LIBRARY_BASE: ${LIBRARY_BASE}"
echo

if [[ ${#LINKS[@]} -eq 0 ]]; then
    pfb warn "No symlinks defined. Edit the LINKS array in this script."
    exit 0
fi

linked=0
skipped=0
missing=0

for entry in "${LINKS[@]}"; do
    local_path="${entry%%:*}"
    target="${entry##*:}"

    if [[ -L "${local_path}" ]]; then
        pfb info "EXISTS   ${local_path}"
        (( skipped++ )) || true
        continue
    fi

    if [[ ! -e "${target}" ]]; then
        pfb warn "SKIP     ${local_path} (target not found: ${target})"
        (( missing++ )) || true
        continue
    fi

    parent_dir="$(dirname "${local_path}")"
    mkdir -p "${parent_dir}"
    ln -s "${target}" "${local_path}"
    pfb success "LINKED   ${local_path} → ${target}"
    (( linked++ )) || true
done

echo
pfb subheading "Linked: ${linked}  |  Already existed: ${skipped}  |  Target not found: ${missing}"
echo
pfb success "Done."
