# Pasada MVP business logic — v1.1 proposal

**Status:** Proposed for field testing. This revision builds on the current [v1.0 brief](business-logic-v1.0.md). The windows, thresholds and pilot targets below are starting hypotheses for Astrolab to validate with commuters and Metro Bus conductors.

## Project details and positioning

| Item | Proposal |
|---|---|
| Team and product | Astrolab · Pasada · `PS` |
| First market | Commuters waiting at selected Metro Bus stops on the Sogod–Ormoc corridor, in both directions |
| Commuter’s question | “Has anyone recently seen a bus for my destination at this stop, and is there likely to be room?” |
| Product promise | Open Pasada without signing in, choose a stop and destination, and see what nearby riders or conductors recently corroborated. Every published observation shows its age. When evidence runs out, the screen says so. |
| Contribution incentive | A rider or conductor can share what they see in a few taps. The next person at that stop gets a better-informed choice about waiting or checking another option. |
| Delivery | Web and Android share one corridor, stop list and set of results. Retain the v1.0 stack of Next.js, React, TypeScript, Tailwind CSS and Supabase PostgreSQL. Android also supports a cached view. |

A sighting describes activity at a stop. Several buses can serve the same direction, so Pasada cannot tell a rider which vehicle they will board or guarantee a seat. Use destination labels **To Ormoc** and **To Sogod** on both clients. Describe alerts as observations in the map and feed. Push notifications and predicted arrival times are outside the pilot.

## Gaps to close before launch

| v1.0 leaves open | Proposed decision | How to settle it |
|---|---|---|
| Which stops have enough contributors to produce useful alerts? | Start with a small published list of stops where riders and conductors can participate in both directions. | A pilot coordinator and local conductors verify stop names, boarding areas, direction and coverage on site before inviting commuters. |
| What makes a report public, fresh or too uncertain to show? | Use the shared publication and expiry rules below. Show missing evidence explicitly. | Rehearse matching, contradictory and expired observations with two independent accounts on different clients. |
| What does offline-first mean for a time-sensitive service? | Android keeps the stop list and last-viewed results. Posting and confirming require connectivity. | Disconnect through an expiry boundary, reconnect and check that an old observation never reappears as fresh. |
| How can a moderator respond to abuse without creating a travel history? | Separate active-report review from account sanctions. Limit what survives expiry as specified below. | Review a flagged report, apply a hit, then verify what remains in storage, logs and backups after expiry. |
| What result would justify expansion? | Measure whether a commuter finds recent evidence and can use it to decide. | Run the short field pilot in Notes before adding stops or vehicle types. |

## User levels

| Level | MVP responsibility |
|---|---|
| E · Guest | Opens either client and reads public stop summaries without an account or location permission. |
| D · Contributor | A commuter or conductor signs in with Google to report, confirm or flag. Both contribute on equal terms. |
| C · Moderator | Reviews flags on active reports, removes inaccurate observations and applies internal guideline hits for verified abuse. |
| B · Administrator | Maintains the pilot stops, direction labels, stop zones and publication settings. Reviews aggregate pilot results. |
| A · System administrator | Operates access controls, expiry, purge and backup recovery. |

## System requirements

1. **Read by stop and destination.** Opening either client shows the corridor and a direction selector. Selecting a stop on the map or in the feed opens the same summary. Show bus activity, seat observations and queue conditions separately, with the age of each published signal. An empty result reads **No recent confirmed report**. A quiet feed gives no evidence that service has stopped.
2. **Report what is visible.** A signed-in contributor selects a pilot stop and destination. A bus observation records **approaching**, **boarding** or **departed**, with an optional seat estimate of **spacious**, **standing room** or **full**. A queue observation records **light**, **moderate** or **heavy** for that boarding direction. Check proximity to the configured stop zone when submitting or confirming. If permission is denied or the device cannot establish proximity, explain why posting is unavailable and keep browsing available. Use a stop pin for display.
3. **Publish only corroborated observations.** Proposed starting rule: two distinct signed-in contributors must independently support the same value at the same stop in the same direction within ten minutes. An unpublished sighting can gain support through a second independent submission. An eligible contributor may also confirm a published value. Count each account once per field, stop and direction in the window, using its latest observation. Evaluate seats separately so a lone seat estimate stays hidden even if bus activity qualifies. If competing values both qualify, show **Reports disagree** for that field. If support drops below threshold, return to the empty state. Recompute when observations expire or are removed.
4. **Handle time and disconnection.** Accept only current, online submissions, timestamped by the service. Each observation expires ten minutes after acceptance, including a confirmation’s own contribution. Show age from the latest supporting observation. On Android, label cached results **Offline** with the last refresh time. When offline, show the cached stop list and remove live status claims, since the device cannot see withdrawals or expiry on the service. Refresh on reconnect before posting.
5. **Correct errors with minimal friction.** A signed-in reader can flag a published summary and select a reason such as wrong stop, stale information or suspected abuse. A flag opens a moderation review. It cannot by itself issue a guideline hit. Removing an underlying observation immediately recalculates the public summary. A moderator can restrict posting for confirmed abuse while preserving access to public information.

## Required solution layers

- **Location and retention.** Request location only during submission or confirmation. Reduce it to a validated stop zone and discard raw coordinates after the check. Public output contains the stop, direction, supported value and age. Keep identity, precise coordinates and individual reports out of the public feed, analytics and routine logs. Hide expired evidence immediately and purge transient records within a proposed five-minute cleanup interval. Exclude transient observations from retained backups, or verify equivalent removal before restored data becomes available.
- **Privacy and enforcement.** Google Sign-In establishes who may contribute. Enforce roles, duplicate suppression and publication thresholds on the service for both clients. Limit report-level identity resolution to active abuse review. Keep any resulting account restriction, reason and expiry separate from stop, direction and report time. Give contributors a short explanation before location use and a way to withdraw permission. Data resale is outside the pilot. Review the actual collection, consent, retention and restore flows against v1.0’s Data Privacy Act requirement before public release.

## MVP features and access

| Launch feature | Access | Acceptance check |
|---|---|---|
| 1. Stop map and directional feed | A–E | A guest can select a destination and stop without signing in. Both clients show the same fresh, conflicting or empty state. |
| 2. Google Sign-In and quick reporting | A–D | A rider at a pilot stop can submit a bus or queue observation. Seat information is optional. One person submitting twice never creates a public alert. |
| 3. Confirm, flag and moderate | A–D confirm or flag. A–C review. | Two matching observations can publish a signal. Removing one of exactly two supporting observations withdraws it on both clients at refresh. |
| 4. Operate the corridor pilot | A–B maintain stop and publication settings. A operates retention and recovery. | The team can correct a stop zone, verify cleanup and recover service without republishing expired reports. A maintained configuration and an aggregate tally are sufficient for launch. |

## Notes — pilot and release decision

Before field testing, Astrolab and participating conductors should choose the stops, validate their zones on representative phones, and agree on test periods for each direction. Include a weak-connectivity session. Verify that one account cannot publish alone, opposing directions stay separate, and a guest never sees an individual contributor.

For a proposed **two-week pilot**, sample at least **20 stop checks per direction** across the agreed travel periods. On a simple tally sheet, record whether a fresh bus status was available and, when available, whether the rider said it helped them decide. Record counts by stop and direction without identities or individual itineraries. Proposed expansion threshold: in **each direction**, at least **60%** of checks find a fresh status and at least **70%** of riders who saw one say it helped. Any confirmed location exposure blocks expansion until corrected. If coverage falls short, adjust the staffed stops or participation periods and repeat the pilot before changing the privacy threshold.

Defer additional corridors and PUV types, ML arrival estimates, public reputation, rewards and advanced analytics. The first release needs enough reliable observations to answer one commuter’s question at one stop.
