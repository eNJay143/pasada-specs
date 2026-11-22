# 01 — Architecture

**Purpose:** Read first to identify who owns a change and which boundaries have evidence.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

Pasada names Web and Android as its allowed platforms. Its workspace separates each client, a back-end API, and shared specifications into sibling Git repositories. The only end-to-end flows that can be traced today are document and release workflows. Google Sign-In is a requirement. The checkout does not establish how a client, server or data store exchanges identity or application data.

| Component | Ownership | Evidence |
|---|---|---|
| `pasada-web/` | Web client changes | Directory, allowed platform and web product scope |
| `pasada-android/` | Android client changes | Directory, allowed platform and Android product scope |
| `pasada-api/` | Back-end changes | Directory and server scope in the Git guide |
| `pasada-specs/` | Shared requirements, release conventions, research instructions and this handbook | Local files listed in 00 |

## Flows and boundaries

1. **Research, specified.** The latest business-logic file supplies the study focus. Verified sources supply findings. The prescribed deliverable is `pasada-specs/planning/sense-making.csv`. The present brief still lacks a focal issue. See 04 #5.
2. **Release, specified.** Development on `main` → QA on `beta` → published bundle from `release` → independent candidate testing → approval → deployment of that exact candidate. The specs equivalent ends with an approved baseline. See 10.
3. **Runtime, unverified.** Trace the first implemented feature from the client entry point through authentication and API handling to any persistence and back to the UI. At present even the location of token verification is open. See 08 and 09.

### Decision: Separate candidate testing from production approval (date unrecorded, author unrecorded)
**Status:** accepted in the written Git policy.
**Context:** QA, independent testers and the final approver evaluate different claims.
**Choice:** test a published bundle, then deploy the exact approved candidate.
**Alternatives:** the guide explicitly rules out independent testing of unreleased development code. Other alternatives are unrecorded.
**Consequences:** rebuilding after approval breaks the link between the tested artifact and production. See 04 #3.

## Inherited tradeoff and ranked debt

Separate repositories permit separate histories and tags. **Inferred cost:** a requirements change has no single cross-repository diff. The following work is ranked by what it unblocks.

1. Name the product, features and actors in the brief so implementation and access-control reviews can refer to the same behavior.
2. Record the first client/API identity and data flow so authorization, location handling and retention can be checked end to end.
3. Record the first reproducible build and artifact identity per product so the release policy can be rehearsed.

Sources: [business brief](../business-logic-v1.0.md) and [Git policy](../git-guidelines.md).
