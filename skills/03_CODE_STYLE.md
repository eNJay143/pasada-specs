# 03 — Code style and commits

**Purpose:** Use the conventions a reviewer can check before a language toolchain exists.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

The [Git guidelines](../git-guidelines.md) supply the only verified style tooling contract here. No formatter, linter, language, logging package or error-handling convention is declared in the product checkouts.

| When writing | Convention and reason |
|---|---|
| Commit header | Use `scope: Imperative summary`, sentence case, no closing period. Aim to fit the whole first line in 50 characters, which satisfies both the summary limit and the quick reference. This keeps the change legible in short history views. |
| Scope | Use the most specific product/subsystem covering the change. Split independent changes so each can be reviewed or reverted separately. Shared feature names span clients, API and specs (04 #2). |
| Body and references | Add a blank line after the header when supplying a body, and wrap it at 72 characters. Describe the reason and include a human-readable description beside ticket numbers so the history works without the tracker. |
| Breaking change | The guide's literal example uses `api:! Remove deprecated /v1/login endpoint` and a `BREAKING CHANGE:` trailer. Preserve the documented punctuation when interpreting its examples. This example supplies no Pasada route (06 #2). |
| Attribution | The guide excludes AI agents as authors of commits, tags, releases and PRs. Keep contributor credit on direct edits and inbox entries so their observations remain traceable. |

**Guidance for the first implementation.** Put the reason for an unusual guard at the affected line and link its failing test or incident. A comment that repeats the condition gives the next editor no reason to retain it. Record actual exception types, user-visible messages and safe log fields here when the first handler lands. Today the brief's location and per-user-trail restrictions already constrain what can be logged (09).
