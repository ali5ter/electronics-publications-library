#!/usr/bin/env bash
# bootstrap.sh — Full reconstruction pipeline for a publication-library instance.
#
# Reconstructs the complete library from a clean clone:
#   1. Validates configuration (.env, LIBRARY_BASE)
#   2. Initialises the lib/pfb submodule if needed
#   3. Creates cloud-storage directories for each collection
#   4. Runs init-symlinks.sh to restore local symlinks
#   5. Downloads PDFs for each collection (skips if already present)
#   6. Converts PDFs to searchable Markdown (skips if already done)
#   7. Regenerates the cross-collection CATALOGUE.md
#
# Name:         bootstrap.sh
# Description:  Full reconstruction pipeline for a publication-library instance
# Author:       Alister Lewis-Bowen <alister@lewis-bowen.org>
# Usage:        ./bootstrap.sh
# Dependencies: bash 4+, python3, pymupdf, git, lib/pfb (submodule)
# Exit codes:   0 success, 1 error
#
# Configuration (via .env or environment):
#   LIBRARY_BASE  Absolute path to the root of your cloud-synced library storage.
#                 See .env.template for examples.

set -euo pipefail

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Source .env if present
if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    # shellcheck source=/dev/null
    source "${SCRIPT_DIR}/.env"
fi

# Initialise lib/pfb submodule if not already done
if [[ ! -f "${SCRIPT_DIR}/lib/pfb/pfb.sh" ]]; then
    echo "Initialising lib/pfb submodule..."
    git submodule update --init lib/pfb
fi

PFB="${SCRIPT_DIR}/lib/pfb/pfb.sh"

# ---------------------------------------------------------------------------
# Validate required configuration
# ---------------------------------------------------------------------------

"${PFB}" heading "publication-library bootstrap" "📚"
echo

if [[ ! -f "${SCRIPT_DIR}/.env" ]]; then
    "${PFB}" error ".env not found."
    "${PFB}" subheading "Copy .env.template to .env and set LIBRARY_BASE:"
    "${PFB}" subheading "  cp .env.template .env"
    exit 1
fi

if [[ -z "${LIBRARY_BASE:-}" ]]; then
    "${PFB}" error "LIBRARY_BASE is not set in .env."
    "${PFB}" subheading "Edit .env and set LIBRARY_BASE to your cloud storage root."
    exit 1
fi

"${PFB}" info "LIBRARY_BASE: ${LIBRARY_BASE}"
echo

# ---------------------------------------------------------------------------
# Helper: parse Source URL from a COLLECTION.md
# @param $1  Path to COLLECTION.md
# @return    Prints the source URL, or empty string if not found
# ---------------------------------------------------------------------------
parse_source_url() {
    local col_md="${1}"
    [[ -f "${col_md}" ]] || { echo ""; return; }
    # Match:  | **Source** | [text](URL) |
    local url
    url="$(grep -oP '\|\s+\*\*Source\*\*\s+\|\s+\[[^\]]+\]\(\K[^)]+' "${col_md}" || true)"
    echo "${url}"
}

# ---------------------------------------------------------------------------
# Phase 1 — Create cloud-storage directories
# ---------------------------------------------------------------------------

"${PFB}" heading "Creating cloud-storage directories" "☁️"
echo

mkdir -p "${LIBRARY_BASE}/findings"
"${PFB}" success "READY  ${LIBRARY_BASE}/findings"

for col_dir in "${SCRIPT_DIR}/collections"/*/; do
    [[ -d "${col_dir}" ]] || continue
    name="$(basename "${col_dir}")"
    mkdir -p "${LIBRARY_BASE}/collections/${name}/pdfs"
    "${PFB}" success "READY  ${LIBRARY_BASE}/collections/${name}/pdfs"
    mkdir -p "${LIBRARY_BASE}/collections/${name}/indexed"
    "${PFB}" success "READY  ${LIBRARY_BASE}/collections/${name}/indexed"
done

echo

# ---------------------------------------------------------------------------
# Phase 2 — Restore symlinks
# ---------------------------------------------------------------------------

"${PFB}" heading "Restoring symlinks" "🔗"
echo
"${SCRIPT_DIR}/init-symlinks.sh"
echo

# ---------------------------------------------------------------------------
# Phase 3 — Download PDFs
# ---------------------------------------------------------------------------

"${PFB}" heading "Downloading PDFs" "⬇️"
echo

for col_dir in "${SCRIPT_DIR}/collections"/*/; do
    [[ -d "${col_dir}" ]] || continue
    name="$(basename "${col_dir}")"
    col_md="${col_dir}COLLECTION.md"

    source_url="$(parse_source_url "${col_md}")"

    if [[ -z "${source_url}" ]]; then
        "${PFB}" warn "SKIP  ${name} — no Source URL in COLLECTION.md"
        continue
    fi

    # Count PDFs already present (follow symlinks)
    pdf_count="$(find -L "${col_dir}pdfs" -name "*.pdf" 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "${pdf_count}" -gt 0 ]]; then
        "${PFB}" info "SKIP  ${name} — ${pdf_count} PDFs already present"
        continue
    fi

    "${PFB}" subheading "${name} — downloading from ${source_url}"
    python3 "${SCRIPT_DIR}/download.py" "${source_url}" \
        --output-dir "collections/${name}/pdfs"
    "${PFB}" success "DONE  ${name}"
done

echo

# ---------------------------------------------------------------------------
# Phase 4 — Convert PDFs to Markdown
# ---------------------------------------------------------------------------

"${PFB}" heading "Converting PDFs to Markdown" "📄"
echo

for col_dir in "${SCRIPT_DIR}/collections"/*/; do
    [[ -d "${col_dir}" ]] || continue
    name="$(basename "${col_dir}")"

    # Skip if indexed output already exists and is non-empty
    indexed_count="$(find -L "${col_dir}indexed" -name "index.md" 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "${indexed_count}" -gt 0 ]]; then
        "${PFB}" info "SKIP  ${name} — already converted (${indexed_count} index files)"
        continue
    fi

    # Skip if there are no PDFs to convert
    pdf_count="$(find -L "${col_dir}pdfs" -name "*.pdf" 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "${pdf_count}" -eq 0 ]]; then
        "${PFB}" warn "SKIP  ${name} — no PDFs found in collections/${name}/pdfs"
        continue
    fi

    "${PFB}" subheading "${name} — converting ${pdf_count} PDFs"
    python3 "${SCRIPT_DIR}/convert.py" \
        --input-dir "collections/${name}/pdfs" \
        --output-dir "collections/${name}/indexed" \
        --pattern "**/*.pdf" \
        --write-collection-md
    "${PFB}" success "DONE  ${name}"
done

echo

# ---------------------------------------------------------------------------
# Phase 5 — Regenerate catalogue
# ---------------------------------------------------------------------------

"${PFB}" heading "Regenerating CATALOGUE.md" "🗂️"
echo
python3 "${SCRIPT_DIR}/convert.py" --global-index collections/
echo
"${PFB}" success "Done. Library reconstruction complete."
