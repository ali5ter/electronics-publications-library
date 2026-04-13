# electronics-publications-library — Claude Code Context

## Library orientation

**Read [`LIBRARIAN.md`](LIBRARIAN.md) before navigating the collections.** It explains the library
structure, how to find and read index files, how to search, and how to write findings.

## Purpose

A personal electronics publications library. Indexed from PDF archives at
[World Radio History](https://www.worldradiohistory.com).

Template repository: <https://github.com/ali5ter/publication-library>

## Collections

| Collection | Period | Publications | Pages | Status |
| --- | --- | --- | --- | --- |
| [Hobby Electronics](collections/hobby-electronics/COLLECTION.md) | November 1978 – September 1984 | 67 | ~5,000 | Indexed |
| [ETI — Electronics Today International](collections/eti/COLLECTION.md) | 1972–1999 | 326 | 27,328 | Indexed |
| [Everyday Electronics](collections/everyday-electronics/COLLECTION.md) | November 1971 – December 1999 | 332 | 24,430 | Indexed |
| [Bernards/Babani BP Books](collections/bernards-babani/COLLECTION.md) | Various (1960s–1990s) | 111 | 16,153 | Indexed |
| [Electronics & Music Maker / Music Technology](collections/electronics-music-maker/COLLECTION.md) | March 1981 – May 1994 | 132 | 12,554 | Indexed |
| [Elektor](collections/elektor/COLLECTION.md) | December 1974 – December 1989 | 160 | 9,165 | Indexed |
| [Moritz Klein](collections/moritz-klein/COLLECTION.md) | Ongoing | 4 | 207 | Indexed |

## Project layout

```text
electronics-publications-library/
├── collections/                  ← local PDF archives and indexed output (gitignored)
│   ├── hobby-electronics/
│   │   ├── COLLECTION.md         ← tracked collection metadata
│   │   ├── pdfs/                 ← source PDFs (gitignored; symlinked to cloud storage)
│   │   └── indexed/              ← 67 issues, fully indexed (~5,000 pages; gitignored)
│   ├── eti/
│   │   ├── COLLECTION.md
│   │   ├── pdfs/                 ← 326 PDFs (gitignored; symlinked to cloud storage)
│   │   └── indexed/              ← 326 dirs, 27,328 pages (gitignored)
│   ├── everyday-electronics/
│   │   ├── COLLECTION.md
│   │   ├── pdfs/                 ← 332 PDFs (gitignored; symlinked to cloud storage)
│   │   └── indexed/              ← 332 dirs, 24,430 pages (gitignored)
│   ├── bernards-babani/
│   │   ├── COLLECTION.md
│   │   ├── pdfs/                 ← 111 BP-numbered books (gitignored; symlinked to cloud storage)
│   │   └── indexed/              ← 111 dirs, 16,153 pages (gitignored)
│   ├── electronics-music-maker/
│   │   ├── COLLECTION.md
│   │   ├── pdfs/                 ← 132 PDFs (gitignored; symlinked to cloud storage)
│   │   └── indexed/              ← 132 dirs, 12,554 pages (gitignored)
│   ├── elektor/
│   │   ├── COLLECTION.md
│   │   ├── pdfs/                 ← 160 PDFs (gitignored; symlinked to cloud storage)
│   │   └── indexed/              ← 160 dirs, 9,165 pages (gitignored)
│   └── moritz-klein/
│       ├── COLLECTION.md
│       ├── pdfs/                 ← 4 PDFs (gitignored; symlinked to cloud storage)
│       └── indexed/              ← 4 dirs, 207 pages (gitignored)
├── findings/                     ← personal research outputs (gitignored; symlinked to cloud storage)
├── lib/
│   └── pfb/                      ← pretty-feedback terminal output library (submodule)
├── LIBRARIAN.md                  ← AI orientation guide (read this first)
├── CATALOGUE.md                  ← master cross-collection index (tracked)
├── download.py                   ← scrape and download PDFs from an archive page
├── convert.py                    ← convert PDFs → markdown + page PNGs
├── search.py                     ← search across indexed collections with formatted output
├── init-findings.sh              ← scaffold the findings/ directory
├── init-symlinks.sh              ← recreate cloud-storage symlinks (auto-derived from collections/)
├── bootstrap.sh                  ← full reconstruction pipeline from a clean clone
├── .env.template                 ← configuration template (copy to .env and set LIBRARY_BASE)
├── README.md
├── CLAUDE.md                     ← this file
├── .gitignore
└── .markdownlint.json
```

## Quick reference

| Task | Location |
| --- | --- |
| All collections | `CATALOGUE.md` |
| Collection details | `collections/NAME/COLLECTION.md` |
| Browse a collection | `collections/NAME/indexed/index.md` |
| Scan an issue | `collections/NAME/indexed/SLUG/index.md` |
| Read full text | `collections/NAME/indexed/SLUG/content.md` |
| Search | `python3 search.py "term"` |
| Write findings | `findings/` (gitignored) |

## Common commands

```bash
# Scaffold findings/ directory
./init-findings.sh

# Full reconstruction from a clean clone (downloads, converts, catalogues)
cp .env.template .env   # then edit .env and set LIBRARY_BASE
./bootstrap.sh

# Restore symlinks only (LINKS auto-derived from collections/; override via .env)
./init-symlinks.sh

# Search across all indexed collections
python3 search.py "topic"

# Search within one collection
python3 search.py "topic" --collection hobby-electronics

# Regenerate the cross-collection catalogue
python3 convert.py --global-index collections/

# Download a new collection
python3 download.py "https://www.worldradiohistory.com/PAGE.htm" \
  --output-dir collections/NAME/pdfs

# Probe a collection before converting
python3 convert.py --analyze --input-dir collections/NAME/pdfs

# Convert and auto-generate COLLECTION.md
python3 convert.py --input-dir collections/NAME/pdfs \
  --output-dir collections/NAME/indexed \
  --write-collection-md
```

## Instance guidance (for forks and template instances)

### Which files are safe to modify in an instance

| File | Safe to edit in instance? | Notes |
| --- | --- | --- |
| `CATALOGUE.md` | Yes — freely | Gitignored in template; instance-owned and generated |
| `collections/*/COLLECTION.md` | Yes — freely | Gitignored in template; instance-owned |
| `findings/` | Yes — freely | Gitignored in template; personal research |
| `CLAUDE.md` | Carefully — see below | Tracked in template; edits risk merge conflicts on sync |
| All other tracked files | No | Modify via upstream PR instead |

### Adding instance-specific Claude context

`CLAUDE.md` is tracked in the template, so direct edits risk merge conflicts when syncing upstream
changes. To add instance-specific context safely, append an `## Instance context` section at the
bottom of your local `CLAUDE.md`. Template content lives above this divider; your additions live
below. When merging upstream changes, conflicts will be isolated to that one section and easy to
resolve.

> **Warning:** Do not commit personal paths (home directories, usernames, cloud storage roots) into
> `CLAUDE.md` or any other tracked file. Keep personal paths in `.env` (gitignored) and reference
> them via environment variables such as `LIBRARY_BASE`.

```markdown
## Instance context

<!-- Instance-specific content below this line — not part of the upstream template -->

### Collections

...your local collection notes here...
```

## Contributing

Report bugs and request enhancements via [GitHub Issues](https://github.com/ali5ter/publication-library/issues).

## Instance context

<!-- Instance-specific content below this line — not part of the upstream template -->

### Setup notes

- All PDFs, indexed output, and findings are symlinked to cloud storage via `LIBRARY_BASE`
- Copy `.env.template` to `.env` and set `LIBRARY_BASE`, then run `init-symlinks.sh`
- When adding a new collection: create cloud storage directories first, run `init-symlinks.sh`,
  *then* run `download.py`

### Versioning

Instance uses `v1.4.x` tags. Upstream remote is configured with `--no-tags` so upstream
template tags no longer land in this namespace on merge. Stray upstream tags (`v1.5.x`,
`v1.6.x`, `v2.x`) have been removed from this repo.

### Release history (this instance)

| Version | Notes |
| --- | --- |
| v1.4.14 | Merge upstream v1.8.0: .env.template, README.md, bootstrap.sh updated for new cloud layout |
| v1.4.13 | Restructure cloud storage to mirror repo layout; fixes relative links in findings in Typora; closes #11 |
| v1.4.12 | Merge upstream #27 (search.py symlink fix) and #28 (--global-index no longer needs --input-dir) |
| v1.4.11 | Add Elektor 1974–1989 (160 issues, 9,165 pages); fix year-month slug for space-separated filenames; closes #4 |
| v1.4.10 | Add Electronics & Music Maker / Music Technology (132 issues, 12,554 pages); closes #3 |
| v1.4.9 | Merge upstream v1.6.0: bootstrap.sh reconstruction pipeline; init-symlinks.sh auto-derives LINKS; closes #5, #6 |
| v1.4.8 | Merge upstream v1.5.0: parametrised init-symlinks.sh (LIBRARY_BASE), pfb submodule, personal paths removed |
| v1.4.7 | Add Everyday Electronics (332 issues, 24,430 pages); all symlinks in place; add init-symlinks.sh |
| v1.4.6 | Complete CATALOGUE.md with full page counts; absorbed upstream v1.4.3–v1.4.5 |
| v1.4.2 | Document upstream sync workflow |
| v1.4.1 | Slug collision bugfix |
| v1.4.0 | Cloud storage symlink guidance |
