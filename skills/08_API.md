# 08 — API

**Purpose:** Check the status of the client/server contract before writing a caller or documenting an endpoint.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

| Contract inventory | Local evidence |
|---|---|
| Entry point and routing | `pasada-api/` contains only an empty instruction file outside Git metadata. Registered routes and methods observed: zero. |
| Authentication and authorization | The brief requires Google Sign-In and lists role labels. Token transport, verification and per-route access remain unspecified. |
| Requests and responses | No validator, response envelope, status-code policy, pagination contract or error registry. |
| Compatibility | Product release tags are specified. An HTTP versioning scheme and client compatibility window are open. |

The paths `/v1/login`, `/v2/auth` and `/auth/refresh` occur in the Git guide's example commit messages. Copying them into a client would create a dependency on a route with no handler (06 #2).

**Procedure for the first endpoint (proposed).**

1. Name the feature and allowed actors in the business brief (04 #1). An unnamed MVP row cannot establish access.
2. Record method, path, input, success response, error cases, authentication and role decisions together. For location data, specify permitted output and retention (04 #6).
3. Once a server framework exists, identify the actual router, validator, authorization check and handler in this document. Trace each client that consumes the response.
4. Exercise an allowed caller, an unauthorized caller and invalid input through the registered route. Record the observed response in 11. *Miss →* a handler-level test can pass while the public route is missing or permits the wrong role.
