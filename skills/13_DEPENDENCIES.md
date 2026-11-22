# 13 — Dependencies

**Purpose:** Distinguish required capabilities and authoring tools from installed software.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

No product manifests, lockfiles, pinned versions or dependency-upgrade policy exist locally. No evidence records a framework rejection. A directory name alone cannot identify the language, SDK or package manager.

| Name in the sources | Reason it appears | Change or upgrade trap |
|---|---|---|
| Google Sign-In | Required sign-in capability in the [brief](../business-logic-v1.0.md). | No client SDK, backend verifier or version is selected. Record supported client/server combinations when adding the first integration (08–09). |
| Git | Each child has its own repository. The release guide uses commits, annotated tags and promotion branches. | Preserve tags and branch semantics when changing release tooling or old approvals become hard to trace (04 #3–4). |
| GitHub | The guide distinguishes tags and separately published Releases. | A created tag alone supplies no downloadable deployment artifact. See 10. |
| PowerShell and ripgrep | Used for local inventory and verification in this edition. | These are authoring tools available during inspection. A future product build needs its own manifest and reproducible command. |

When the first external package lands, record its reason, version source, compatible clients and the check that would catch an incompatible upgrade. Attribute any rejected alternative to a decision record so a future reader can distinguish a reviewed choice from a package nobody considered.
