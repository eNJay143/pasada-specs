# 15 — Known limitations

**Purpose:** Find the gaps most likely to turn a plausible assumption into an incorrect change.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

Ranked by likely surprise to a newcomer. The ranks are editorial judgments. Each status describes the local snapshot.

| Rank | Limitation | Effect and evidence needed to close it |
|---|---|---|
| 1 | The parent workspace has no Git history and each child has an unborn branch. | Inspect each child's working files. A real baseline needs a revision in its owning repo (06 #1). |
| 2 | The Git guide mixes reusable examples, dated retrospective text and empty release tables. The product identity is still a placeholder. | Local refs support no historical releases. Resolve names, weekly versus candidate context and the maintenance trigger before assigning tags (04 #2–4, 10). |
| 3 | The MVP matrix lists seven access patterns for unnamed features. Moderator and Contributor have no descriptions. Requirements 2–7 are placeholders. | Access and acceptance tests cannot express user intent until those entries are named (04 #1). |
| 4 | Google Sign-In and location privacy are requirements with no implementation evidence. Retention periods, thresholds and consent semantics remain open. | Compliance and enforcement are unverified. A design and implementation trace are needed (07, 09). |
| 5 | No runnable entry point, schema, dependency manifest, environment contract, test suite or deployment configuration. | Runtime behavior, defects, coverage and performance remain unknown (07–13). |
| 6 | The environmental scan has a format and output destination but no defined focal issue in the initial brief. | Completing the study brief enables a meaningful scan (14 #4). |

**Ranked design candidates (inferred).** First, define the feature–role matrix because every authorization decision consumes it. Second, define the identity and location lifecycle because it spans clients, server and future storage. Third, reconcile product identity and release evidence because labels must identify real artifacts. There is no existing runtime design or recorded production bug to rank for redesign.
