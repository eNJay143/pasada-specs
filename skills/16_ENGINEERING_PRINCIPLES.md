# 16 — Engineering principles

**Purpose:** Use these rules when a document, a checkout and a release claim appear to disagree.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

1. **Inspect the repository that owns the claim.** The parent has no Git metadata, while the specs child contains meaningful untracked files. A failed history query at the root would conceal both facts. Source story: 06 #1.
2. **Trace a release claim to its revision.** The Git guide binds published candidates to immutable tags and exact builds. Its retrospective and empty tables illustrate how readily an example becomes apparent history. Source story: 06 #2. Apply the check in 04 #3–4.
3. **Keep observations distinct from requirements.** Google Sign-In is a written requirement. The checkouts contain no route that could verify a login. The same distinction kept an example login endpoint out of the API inventory (06 #2, 08).

These initial rules reflect the evidence in this edition. Propose later promotions through the inbox with a source story and user decision. Preserve numbering when appending them.

trust the code over any document, including this one
