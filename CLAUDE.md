# electronics-publications-library — Claude Code Context

## Library orientation

**Read [`LIBRARIAN.md`](LIBRARIAN.md) before navigating the collections.** It explains the library
structure, how to find and read index files, how to search, and how to write findings.

## Purpose

A personal electronics publications library. Indexed from PDF archives at
[World Radio History](https://www.worldradiohistory.com).

Template repository: <https://github.com/ali5ter/publication-library>
Local directory: `/Users/alister/Documents/Projects/electronics-publications-library/`

## Collections

| Collection | Period | Publications | Pages | Status |
| --- | --- | --- | --- | --- |
| [Hobby Electronics](collections/hobby-electronics/COLLECTION.md) | November 1978 – September 1984 | 67 | ~5,000 | Indexed |
| [ETI — Electronics Today International](collections/eti/COLLECTION.md) | 1972–1999 | 326 | 27,328 | Indexed |
| [Bernards/Babani BP Books](collections/bernards-babani/COLLECTION.md) | Various (1960s–1990s) | 111 | 16,153 | Indexed |
| [Moritz Klein](collections/moritz-klein/COLLECTION.md) | Ongoing | 4 | 207 | Indexed |

## Project layout

```text
electronics-publications-library/
├── collections/                  ← local PDF archives and indexed output (gitignored)
│   ├── hobby-electronics/
│   │   ├── COLLECTION.md         ← tracked collection metadata
│   │   ├── pdfs/                 ← source PDFs (gitignored; to be symlinked to cloud storage)
│   │   └── indexed/              ← 67 issues, fully indexed (~5,000 pages; gitignored)
│   ├── eti/
│   │   ├── COLLECTION.md
│   │   ├── pdfs/                 ← 367 PDFs (gitignored; to be symlinked to cloud storage)
│   │   └── indexed/              ← 327 dirs, 27,328 pages (gitignored)
│   └── bernards-babani/
│       ├── COLLECTION.md
│       ├── pdfs/                 ← 111 BP-numbered books (gitignored; to be symlinked)
│       └── indexed/              ← 111 dirs, 16,153 pages (gitignored)
├── findings/                     ← personal research outputs (gitignored)
├── LIBRARIAN.md                  ← AI orientation guide (read this first)
├── CATALOGUE.md                  ← master cross-collection index (tracked)
├── download.py                   ← scrape and download PDFs from an archive page
├── convert.py                    ← convert PDFs → markdown + page PNGs
├── search.py                     ← search across indexed collections with formatted output
├── init-findings.sh              ← scaffold the findings/ directory
└── README.md
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
# Search across all indexed collections
python3 search.py "topic"

# Search within one collection
python3 search.py "topic" --collection hobby-electronics

# Regenerate the cross-collection catalogue
python3 convert.py --global-index collections/

# Download a new collection
python3 download.py "https://www.worldradiohistory.com/PAGE.htm" \
  --output-dir collections/NAME/pdfs

# Convert a collection
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

- Private remote to be added once cloud storage symlinks are in place
- PDFs and indexed output are gitignored; to be symlinked to cloud storage
- `findings/` is gitignored; to be symlinked to cloud storage

### Release history (this instance)

| Version | Notes |
| --- | --- |
| v1.4.6 | Complete CATALOGUE.md with full page counts; absorbed upstream v1.4.3–v1.4.5 |
| v1.4.2 | Document upstream sync workflow |
| v1.4.1 | Slug collision bugfix |
| v1.4.0 | Cloud storage symlink guidance |
