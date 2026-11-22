# 11 — Testing

**Purpose:** Choose a check that can detect the failure and identify what still requires executable code.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

No test runner, fixtures, mocks, test suites, build workflow or coverage reports are present. Runtime coverage is unknown. The written policy assigns developer unit testing to `main`, QA system testing to `beta`, and independent integration testing to published bundles from `release` (10).

## Manual drills available now

| Drill | Expected result | Failure caught |
|---|---|---|
| Read each MVP row and resolve every role letter in User Levels. | Every letter maps to one role. Row 1 includes E, row 7 only A. Feature names still need definition. | A role rename silently changes who can act (04 #1). |
| Walk the guide's sample web build through a beta failure. | `WCN.01.0.017b` → `WCN.01.0.017b2` → `WCN.01.0.017rc` after passing. | Candidate iteration incorrectly changes the build or carries the suffix to the next stage (04 #3). |
| Compare release tables to local history. | Each claimed real tag needs a corresponding ref and commit in its owning repo. The initial tables are empty. | Template examples become reported releases (06 #2). |

When a research CSV exists, parse it as CSV (PowerShell's `Import-Csv` is available). Check the literal header against `sense-making.md`, seven allowed factor names, at least two findings and three credible sources per factor, independent integer scores from 1 to 5 and no total. Check each finding and APA entry against its 256-character limit, raw double-quote escaping and cited source. A parser alone cannot detect a fabricated citation or determine whether the research answers the brief (04 #5).

## First executable checks (proposed)

For authentication, exercise a valid session, an invalid identity and guest access through each affected client and server route. For aggregation, test values below, at and above the chosen threshold. For retention, include old records and restored copies. For releases, compare the tested artifact with the approved one. A mock provider can isolate denial and expiry cases once the integration is picked. A real integration check is still needed to catch a mismatched client or provider configuration. None of these runtime checks has been executed here.
