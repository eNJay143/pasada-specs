# 04 — Change rules

**Purpose:** Review these coupled files and sections together when changing a shared name, policy or format.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

This inventory covers the current source files. No runtime enums, DTOs, column lists, error codes or registries exist in the product checkouts. The first shared constants are in prose.

### 1. Role identifiers and access
1. `pasada-specs/business-logic-v1.0.md` → **User Levels** defines A through E.
2. Same file → **MVP Features and Access** uses those letters on seven unnamed rows.

Trace every letter in the matrix back to one role after a rename. Read the changed row as each affected role. *Miss →* a valid-looking letter can silently grant the wrong audience access. Runtime enforcement remains open (08, 09).

### 2. Product identity, scopes and prefixes
1. `pasada-specs/business-logic-v1.0.md` → **Project Details** holds the code name and short code.
2. `pasada-specs/git-guidelines.md` → **Preferred application scopes**, **Ecosystem-wide identity**, **Product prefixes**, tag examples and the four product tables mirror that identity.
3. Check the real sibling directory names in 02. Android is called `app` in example scopes and `android` in its tag-table heading.

Read one proposed scope and tag for each product. *Miss →* commits become hard to find or a tag claims the wrong product. The prefix letters W/B/A/S distinguish web, backend, Android and specs respectively.

### 3. Promotion, candidate label and artifact
1. `pasada-specs/git-guidelines.md` → **Promotion rules** determines the source branch and approval gate.
2. Same file → **Release Testing and Approval** and **Pre-release label** bind each candidate label to the published build.
3. Same file → **Release Tags** binds the tag to history.

Match the published candidate, tested revision and final approval. Rehearse a failed beta candidate (11). *Miss →* an untested rebuild can inherit the previous candidate's approval.

### 4. Version counters and weekly history
1. `pasada-specs/git-guidelines.md` → **Rules** and **Production Support and Maintenance** define when counters advance.
2. Same file → **Applying the rules to specifications** changes the meaning of deployment for specs.
3. Same file → **Creating a release**, **How the tags were derived** and the product tables. Compare to that product's actual commits and tags (05, 06 #2).

Recheck ISO week, committer date, weekly cutoff, version padding and prior tag target before updating a row. *Miss →* a plausible build number can refer to a week with no changes or an unsupported historical release.

### 5. Research input, serialization and output
1. `pasada-specs/business-logic-v1.0.md` supplies the focal issue to the research brief.
2. `pasada-specs/sense-making.md` defines the seven factors, columns, quotas, quoting, evidence checks and destination.

Review the latest brief first, then parse the eventual CSV and check the contract in 11. *Miss →* a syntactically valid scan can address the wrong problem, or a comma in a citation can shift the scores.

### 6. Privacy across future data surfaces
1. `pasada-specs/business-logic-v1.0.md` → **Required Solution Layers** couples location protection, retention, per-user trails, aggregation and resale consent.
2. When implementation arrives, trace each new field across client collection, transport, storage, logs and exports (07, 09).

*Miss →* deleting a primary record can leave a reconstructable trail elsewhere. **Inferred risk.** These surfaces have no verified implementation yet.
