# 02 — Project structure

**Purpose:** Find the repository that owns a file before editing or running Git.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

Verified tree at the first handoff. Each child repository has its own `.git` directory and an empty `AGENTS.md`.

```text
pasada-ecosystem/                 workspace directory
  AGENTS.md                       empty workspace instructions
  handoff.md                      handbook format and upkeep
  pasada-android/                 Android repository
  pasada-api/                     server repository
  pasada-web/                     web repository
  pasada-specs/                   shared specifications repository
    business-logic-v1.0.md        product and access requirements
    git-guidelines.md             commit and release policy
    sense-making.md               environmental scan instructions
    skills/                       numbered handoff documents and INBOX.md
```

Put platform code in the matching product repository so its build and history travel together. No package layout or source naming convention has been established inside those repositories. Shared product decisions belong with the specs. The path reserved for the research output is `planning/sense-making.csv` inside specs. The file was absent on inspection.

The workspace root is outside Git. Start Git in the child that owns the change or the command fails (see 06 #1). The Android directory is named `pasada-android`, while the commit policy uses the template scope `code-name-app`. Resolve the product short code before assigning real prefixes (see 04 #2). Preserve numbered handbook filenames so existing cross-references keep working.
