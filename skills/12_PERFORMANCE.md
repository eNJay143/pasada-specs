# 12 — Performance

**Purpose:** Identify meaningful limits and the first measurements to record when a workload exists.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

No measured latency, throughput, hot paths, expensive queries, caches, timeouts, rate limits or deliberate runtime inefficiencies appear in the checkouts. There is no profiler command to reproduce. The 256-character limits apply to research CSV fields (04 #5). They say nothing about API payload limits.

| Candidate workload (inferred) | First measurement | Constraint that affects interpretation |
|---|---|---|
| Location aggregation | With representative synthetic data, record group sizes, rows examined and latency around the chosen publication threshold. | Publishing a smaller group to speed up a query would undermine the privacy requirement (09). |
| Retention cleanup | Once a store exists, record oldest retained timestamp, rows expired, duration and foreground impact. | A faster run that skips old copies can leave a trail (07). |

Record the revision, workload size, device or server configuration and observed timings with the first profile. Without them another engineer cannot distinguish a performance regression from a different workload.
