#!/usr/bin/env bash
# init-symlinks.sh — Recreate Dropbox symlinks for the electronics publications library.
#
# All PDFs, indexed output, and findings are stored in Dropbox and linked into
# the project directory. Run this script after cloning or on a new machine to
# restore those links.
#
# Usage:
#   bash init-symlinks.sh
#
# Author: Alister Lewis-Bowen <alister@lewis-bowen.org>
# Dependencies: None (standard macOS/Linux)

set -euo pipefail

DROPBOX_BASE="/Users/alister/Dropbox/Private/Home/Electronics/Library"

# Each entry is: "local_path:dropbox_target"
# - findings       → flat directory in Dropbox
# - */pdfs         → per-collection PDF directory in Dropbox
# - */indexed      → per-collection indexed output under library-indexed/
declare -a LINKS=(
    "findings:${DROPBOX_BASE}/library-findings"
    "collections/hobby-electronics/pdfs:${DROPBOX_BASE}/hobby-electronics"
    "collections/hobby-electronics/indexed:${DROPBOX_BASE}/library-indexed/hobby-electronics"
    "collections/eti/pdfs:${DROPBOX_BASE}/eti"
    "collections/eti/indexed:${DROPBOX_BASE}/library-indexed/eti"
    "collections/bernards-babani/pdfs:${DROPBOX_BASE}/bernards-babani"
    "collections/bernards-babani/indexed:${DROPBOX_BASE}/library-indexed/bernards-babani"
    "collections/moritz-klein/pdfs:${DROPBOX_BASE}/moritz-klein"
    "collections/moritz-klein/indexed:${DROPBOX_BASE}/library-indexed/moritz-klein"
    "collections/everyday-electronics/pdfs:${DROPBOX_BASE}/everyday-electronics"
    "collections/everyday-electronics/indexed:${DROPBOX_BASE}/library-indexed/everyday-electronics"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "Recreating Dropbox symlinks..."
echo

for entry in "${LINKS[@]}"; do
    local_path="${entry%%:*}"
    target="${entry##*:}"

    if [[ -L "${local_path}" ]]; then
        echo "  EXISTS  ${local_path}"
        continue
    fi

    if [[ ! -e "${target}" ]]; then
        echo "  SKIP    ${local_path} (target not found: ${target})"
        continue
    fi

    parent_dir="$(dirname "${local_path}")"
    mkdir -p "${parent_dir}"
    ln -s "${target}" "${local_path}"
    echo "  LINKED  ${local_path} -> ${target}"
done

echo
echo "Done."
