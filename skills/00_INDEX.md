# 00 — Engineering handoff

**Purpose:** Choose a reading path and locate the source behind each claim.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

Read [01](01_ARCHITECTURE.md) first. The workspace contains three product repositories and one specifications repository. The product checkouts have no application files. Git has no local commits or tags in any of the four. This edition can answer what the specs require and how to review a change. Runtime behavior needs fresh evidence.

| If you are here to… | Read in order |
|---|---|
| Make your first change | 01 → 02 → 14 → 03 |
| Change a role, client contract or privacy requirement | 04 → 08 → 09 → 07 → 11 |
| Investigate an error or a historical claim | 05 → 06 → 15 |
| Prepare a candidate | 04 #3–4 → 10 → 11 |
| Choose a dependency or assess cost | 13 → 12 → 15 |

## Baseline and confidence

The **pre-commit snapshot** refers to the local working trees inspected on 2026-11-22. The following SHA-256 prefixes identify the exact input files even before a commit exists. Run `Get-FileHash -Algorithm SHA256 *.md` inside `pasada-specs` to compare.

| Source | SHA-256 prefix | What it establishes |
|---|---|---|
| [Business Logic v1.0](../business-logic-v1.0.md) | `F1A10E6FDC63` | Draft requirements, roles and access matrix |
| [Git Guidelines](../git-guidelines.md) | `1DD760F74C2C` | Commit, branch, candidate and tag policy |
| [Sense making](../sense-making.md) | `03C70A5A9291` | Research deliverable and CSV format |

**Verified** means observed locally or explicitly required in a named source. **Inferred** means a consequence or intended boundary deduced from it. **Unverified** covers claims that lack corroboration. Dates below record inspection of the available evidence.

## Directory

| Document | Last verified |
|---|---|
| [00 — Engineering handoff](00_INDEX.md) | 2026-11-22 |
| [01 — Architecture](01_ARCHITECTURE.md) | 2026-11-22 |
| [02 — Project structure](02_PROJECT_STRUCTURE.md) | 2026-11-22 |
| [03 — Code style and commits](03_CODE_STYLE.md) | 2026-11-22 |
| [04 — Change rules](04_CHANGE_RULES.md) | 2026-11-22 |
| [05 — Debugging playbook](05_DEBUGGING_PLAYBOOK.md) | 2026-11-22 |
| [06 — Failure stories](06_FAILURE_STORIES.md) | 2026-11-22 |
| [07 — Database](07_DATABASE.md) | 2026-11-22 |
| [08 — API](08_API.md) | 2026-11-22 |
| [09 — Security and privacy](09_SECURITY.md) | 2026-11-22 |
| [10 — Deployment and release](10_DEPLOYMENT.md) | 2026-11-22 |
| [11 — Testing](11_TESTING.md) | 2026-11-22 |
| [12 — Performance](12_PERFORMANCE.md) | 2026-11-22 |
| [13 — Dependencies](13_DEPENDENCIES.md) | 2026-11-22 |
| [14 — Developer workflows](14_DEVELOPER_WORKFLOWS.md) | 2026-11-22 |
| [15 — Known limitations](15_KNOWN_LIMITATIONS.md) | 2026-11-22 |
| [16 — Engineering principles](16_ENGINEERING_PRINCIPLES.md) | 2026-11-22 |
| [Contributions inbox](INBOX.md) | 2026-11-22 |

## Contributing and refreshing

Use [INBOX](INBOX.md) for a rough entry or edit the owning document directly. Keep the contributor's credit and evidence. The inbox maps contributions to their homes. After a release, incident, design decision, newly shared contract, full inbox, or several quiet weeks, compare each affected source with its confidence note. Once commits exist, use `git log` and `git diff` in the owning repository. For this first edition use the fingerprints above and include untracked files in the inspection.

Verify inbox entries, merge their substance into the numbered documents with credit, then clear the processed entries. Mark unresolved evidence *unverified*. If accounts conflict, preserve both with their sources and ask the user to resolve the conflict. Keep direct edits. Move superseded guidance to a dated **Retired** section with its replacement and reason. Append identifiers to preserve links. Propose promotions to 16 for user decision. Refresh the verification dates and add the newest change below.

## Changelog

- 2026-11-22 — Created the initial handoff from the three local specs. Recorded the empty product checkouts, the repository boundary and the release-history discrepancy.
