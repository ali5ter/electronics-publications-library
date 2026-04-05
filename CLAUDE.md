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
| [Hobby Electronics](collections/hobby-electronics/COLLECTION.md) | 1978–1984 | 67 | ~5,000 | Indexed |
| [ETI — Electronics Today International](collections/eti/COLLECTION.md) | 1972–1999 | 367 | 27,328 | Indexed |
| [Bernards/Babani BP Books](collections/bernards-babani/COLLECTION.md) | Various | 111 | 16,153 | Indexed |

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

## Notes

- Private remote to be added once cloud storage symlinks are in place
- PDFs and indexed output are gitignored; to be symlinked to cloud storage
- `findings/` is gitignored; to be symlinked to cloud storage
