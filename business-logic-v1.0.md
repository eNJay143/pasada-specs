# Business Logic

> Development of a Web and Android-based Crowdsourced PUV Proximity Alert Platform using Next.js, React, TypeScript, Tailwind CSS, and Supabase for Sogod–Ormoc Commuters

- Allowed Platforms: Web, Android

## Project Details

- Company/Startup/Team Name: `Astrolab`
- Project Code Name: `Pasada`
- Project Short Code: `PS`
- Short Description: `An anonymized, crowdsourced Web and Android platform for real-time PUV proximity alerts, piloting on Metro Bus routes between Sogod and Ormoc (vice versa).`
- Long Description: `Pasada is a community-powered Web and Android application ecosystem that enables daily commuters and public utility vehicle (PUV) operators to anonymously broadcast and discover location-pinned, time-limited transit proximity alerts, seat availability estimates, and waiting-passenger density along fixed local routes. For the first release and initial testing stage (Phase 1 MVP), the scope is strictly focused on Metro Bus operations along the Sogod to Ormoc (vice versa) corridor. Built with Next.js, React, TypeScript, Tailwind CSS, an offline-first Android client, and Supabase, the platform operates without vendor hardware or per-user location history trails and is designed to expand to additional PUV types and privacy-preserving machine learning arrival predictions once the pilot succeeds.`

## User Levels

> Note: Modify/rename the list of users based on the actual users that you expect to use the system.

| User Level              | Description |
| ----------------------- | ----------- |
| A. System Administrator | Maintains/overrides system/server configurations, manages database migrations, and performs regular backups. |
| B. Administrator        | Manages fixed route corridors (starting with Metro Bus Sogod–Ormoc, vice versa), transit stop geofences, aggregation thresholds, and generates periodic anonymized system analytics and reports. |
| C. Moderator            | Reviews community-flagged transit reports and issues community-guideline hits against abusive or spoofed broadcasts. |
| D. Contributor          | Authenticated commuters and Metro Bus operators/conductors on Web or Android who broadcast time-limited bus proximity pings, seat occupancy statuses, and stop queue conditions, and confirm or flag active reports. |
| E. Guest                | Users who do not log in, but view limited contents (live aggregated Metro Bus Sogod–Ormoc proximity alerts and transit stop statuses) on the app/web. |

## System Requirements

1. The app shall allow the users to authenticate using Google Sign-In integration across Web and Android clients.
2. The app shall allow Contributors to broadcast location-pinned, time-limited Metro Bus proximity alerts (approaching, boarding, or departed) and occupancy estimates (spacious, standing room, or full) along the Sogod–Ormoc (vice versa) corridor, with route direction tags (Northbound to Ormoc / Southbound to Sogod).
3. The app shall allow Contributors to post time-limited transit stop waiting conditions (light, moderate, or heavy commuter queue) pinned to valid stop zones along the Sogod–Ormoc corridor.
4. The app shall allow all users (including Guests) on Web and Android to view live, aggregated Metro Bus proximity alerts and stop statuses on an interactive corridor map and directional feed.
5. The app shall allow Contributors to confirm ("still accurate") or flag inaccurate/spoofed proximity alerts to keep community data fresh without displaying public user reputation scores.
6. The app shall automatically expire and purge transient proximity alerts and stop status reports once their time-to-live (TTL) window elapses.
7. The app shall allow Moderators and Administrators to enforce community standards through internal community-guideline hits and manage route/stop definitions (designed to accommodate additional PUV types in future releases) without exposing individual commuter travel trails.

## Required Solution Layers

1. Security and privacy by design. Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, and consent for any data resale.
2. Enforcement works through internal community-guideline hits instead of visible reputation or financial/convertible rewards.

## MVP Features and Access

> See the User Levels table for reference.

| Feature               | Access      |
| --------------------- | ----------- |
| 1. View live aggregated Sogod–Ormoc (vice versa) Metro Bus proximity map and corridor status feed on Web and Android | A,B,C,D,E   |
| 2. Authenticate via Google Sign-In and manage privacy/consent preferences | A,B,C,D     |
| 3. Submit location-pinned, directional, time-limited Metro Bus proximity and seat occupancy pings | A,B,C,D     |
| 4. Submit time-limited transit stop queue density updates and confirm/flag active pings | A,B,C,D     |
| 5. Review flagged broadcasts and apply internal community-guideline hits | A,B,C       |
| 6. Configure route corridors, stop geofences, TTL windows, PUV categories, and view aggregated analytics | A,B         |
| 7. Manage server/system configurations, retention purge jobs, and database backups | A           |

## Notes
- **Phase 1 / First Release Scope:** Strictly limited to **Metro Bus** along the **Sogod–Ormoc (vice versa)** corridor for initial deployment and field testing.
- **Post-Pilot Expansion (Multi-PUV & ML Predictions):** Route and vehicle models remain PUV-agnostic (`puv_type` / `route`) so additional PUV types can be onboarded without schema rewrites. If Phase 1 succeeds and accumulates sufficient anonymized, aggregated stop-level data, Phase 2 will introduce machine learning predictions (e.g., estimated bus arrival windows and peak stop-queue forecasts) trained strictly on de-identified aggregate buckets rather than per-user location trails.
- Target deployment covers all four ecosystem repositories (`pasada-specs`, `pasada-web`, `pasada-api`, and `pasada-android`) backed by Supabase PostgreSQL.
- No monetary, credit, or convertible rewards are offered; contribution payoff is practical (faster commute decisions and shared corridor visibility).
