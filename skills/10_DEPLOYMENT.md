# 10 — Deployment and release

**Purpose:** Trace a candidate from development to approval and determine which parts can be executed.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

| Product | Verified delivery information |
|---|---|
| Web, API, Android | The [Git policy](../git-guidelines.md) defines common gates. Build commands, hosting, credentials, release website URL, signing and rollout mechanisms are absent. |
| Specifications | Review candidates against implementation and stakeholder feedback. An approved baseline handed to implementation starts the specs maintenance lifecycle. |

No cross-product deployment order is specified. Before the first coupled rollout, identify which published clients can use which API revision (08). Otherwise an independently tagged server or client could break the other side.

## Release checklist from the written policy

1. Complete development and developer unit checks on `main`. Promote reviewed work to `beta` for QA system testing against product claims.
2. After QA acceptance, promote to `release`. Planned development must be complete (100% in the WBS/Gantt). Publish the bundle for independent testing. *Miss →* testers can validate a different build from the one offered for approval.
3. Issue `a`, `b`, then `rc` from `release`. A failure creates the next iteration in the same stage, e.g. `b2`. Passing advances to the next bare label. Retain the same build number through these iterations.
4. Record the final approver's decision and deploy the exact approved RC. An immutable tag identifies the revision. Creating a GitHub Release is a separate publishing step.
5. Carry stabilization fixes back to the appropriate development branch. For accepted post-production defects, the support path is Customer Service → Technical Support → Support Engineer → sustaining team. An approved maintenance lifecycle starts from its production baseline.

## Tag arithmetic and outstanding ambiguity

The format is `<prefix>.0X.Y.00Z` with padded major (two digits), maintenance (one digit), and weekly build (three digits). The example `WCN.01.0.017rc2` is the second RC for one example web build. Choose a real short code before using these template prefixes (04 #2). An approved breaking requirements cycle increments major and resets the rest to `0.001`. Opening a maintenance cycle increments minor and resets build to `001`.

For weekly tags, use committer dates and ISO weeks with commits. The first occupied week gets `001`. Preserve chronological order and existing targets. The guide specifies annotated tags at the last commit of each eligible week, a Friday 17:00 local cutoff for the current week and a tag date no earlier than its target commit. Candidate tags must identify published revisions on `release` (04 #3–4).

The retrospective also says to bump minor when production deploys, while the normative maintenance section ties it to opening a maintenance lifecycle. Preserve both readings until a decision owner resolves the trigger. Record any resolution in 01 before using it to assign a real tag. Local release history is unverified (06 #2).
