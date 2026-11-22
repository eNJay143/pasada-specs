# 06 — Failure stories

**Purpose:** Learn from reproducible handoff findings and distinguish them from production incidents.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

No reachable commits, incident reports or runtime traces were available. The following are observations from this handoff. Frequency and production impact are unknown.

### 1. Git history appeared inaccessible at the workspace root

**What happened.** Running `git status --short --branch` in `pasada-ecosystem` returned the repository error quoted in 05. **Why.** Each of the four child directories has its own Git metadata. The parent has none. **How found.** A filesystem inventory showed the siblings. Running status and history with each child as the working directory identified four unborn branches and untracked files. **Resolution.** Inspect each child's status, files and refs separately. **Lesson.** Scope an absence claim to the checkout searched. **Confidence:** verified locally.

### 2. The release narrative has no matching local tag evidence

**What happened.** The guide says weekly tags were reconstructed on 2026-07-04. Its four release tables have empty rows. **Why.** The text uses template project names and historical examples. Their original provenance is unknown. **How found.** Comparing the release section with `git log --all --oneline` and `git tag --list` in the four children found no local refs corroborating a release. **Resolution in this handbook.** Preserve the written tagging rules and label the retrospective unverified. A dated candidate or past production impact would require additional evidence. **Lesson.** Check a tag target before using a retrospective as a release record (04 #4, 16 #2). **Confidence:** verified discrepancy, unknown upstream history.

The concurrency failure, ticket numbers and legacy login endpoint in the commit examples are teaching examples. A future incident entry needs the actual symptom, discovery, affected revision, fix, consequence and contributor credit so a reviewer can distinguish an observed failure from a plausible one.
