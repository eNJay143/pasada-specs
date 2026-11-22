# 07 — Database

**Purpose:** Identify the decisions a persistence change must resolve before anyone can rely on stored data.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

**Verified inventory:** zero schema files, migrations, table definitions or database configuration in the checkouts. The storage engine, table map, primary keys, uniqueness, foreign keys, cascade behavior, indexes, migration tool and rollback procedure are all open. Role letters identify entries in a requirements table. They provide no database identity scheme.

| First design question | Evidence the design needs | Consequence if missed |
|---|---|---|
| What is a user identity? | Document how a Google Sign-In identity relates to any internal identifier and where uniqueness is enforced. | A later change to identity mapping could split one account across records. |
| Which location and time fields survive a write? | Trace stored combinations, derived records and any backup or log copies against the no-per-user-trails requirement (04 #6). | Retained records might reconstruct a person's movements. |
| What expires or is deleted? | Specify retention periods, deletion scope and treatment of restored data. Backup responsibility appears under System Administrator in the brief. | Restoring an old copy could reintroduce expired data. |
| When may an aggregate be read or exported? | Document the threshold, where it is checked, and the resale-consent rule (09). | Small groups could expose a person's contribution. |
| How does a schema change ship? | Record migration order, affected readers, recovery and index evidence with the first schema. | An older client or service may read an incompatible shape. |

These are **inferred design checks** from the [business brief](../business-logic-v1.0.md). There is no verified command to migrate, delete, restore or profile a database here.
