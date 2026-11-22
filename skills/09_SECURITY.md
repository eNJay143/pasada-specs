# 09 — Security and privacy

**Purpose:** Review identity, access and location handling against the requirements that actually exist.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

The [business brief](../business-logic-v1.0.md) requires Google Sign-In, location protection, retention limits, no per-user trails, aggregation thresholds and consent for any data resale. It names Data Privacy Act compliance as a requirement. The checkout contains no control implementation, compliance assessment or accepted risk decision.

| Change checklist | What could break | Evidence to capture |
|---|---|---|
| Trace sign-in and access separately | A signed-in user could receive administrator data. A guest could see unrestricted content. | Identify the identity verification point and the server-side decision for each named feature. See 04 #1 and 08. |
| Trace location through storage, logs, backups and exports | Separate observations may form a per-user trail even if the normal UI hides them. | Record retention, deletion, aggregation thresholds and consent checks at each relevant boundary. See 04 #6 and 07. |
| Review client input at its server destination | Validation or access checks could be absent at a query, command, upload or renderer introduced by a change. | Name the actual input validator and destination once a route exists. No current injection surface is evidenced. |
| Review release configuration | Debug output could expose identity or location data. | Identify the build-time or runtime gate and inspect the published candidate once a build exists. |
| Review credentials referenced by a change | A copied secret in docs or logs survives rotation in historical copies. | Document configuration key names and ownership only. No project secret keys or environment variable names were found. |

Moderator and Contributor are undefined in the brief. Every feature in the matrix is unnamed. No thresholds, retention durations, debug switches or consent mechanism have been chosen in the available sources. Treat these as open decisions when the first affected feature is designed (15).
