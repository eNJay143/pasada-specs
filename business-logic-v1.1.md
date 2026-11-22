# Pasada business logic v1.1 — Metro Bus corridor pilot

## Project Details

**Astrolab · Pasada · `PS` · Web and Android**

At a Metro Bus stop, a commuter wants to know, “Has anyone seen a bus headed my way, and is there room?” Pasada lets them choose **To Ormoc** or **To Sogod**, open a named stop, and see what nearby commuters and conductors recently observed. Each public result shows its age so the rider can decide whether to keep waiting. A sighting describes activity at that stop. It carries no guarantee about the next bus, its arrival time or a particular seat.

Phase 1 serves selected stops on the **Sogod–Ormoc corridor in both directions**. Web and Android use the same stop list, reporting rules and public feed. The delivery scope spans `pasada-web`, `pasada-android`, `pasada-api` and `pasada-specs`, using the [v1.0 stack](business-logic-v1.0.md) of Next.js, React, TypeScript, Tailwind CSS and Supabase PostgreSQL. The numerical settings below are starting values for the field pilot.

## User Levels

| Level | Responsibility |
|---|---|
| E · Guest | Browse public summaries without signing in or sharing location. |
| D · Contributor | Sign in with Google to report, confirm or flag. Commuters and conductors follow the same rules. |
| C · Moderator | Review flags, remove inaccurate observations and issue or revoke internal guideline hits for confirmed abuse. |
| B · Administrator | Maintain pilot stops, boarding locations, directions and pilot settings. Review aggregate pilot results. |
| A · System administrator | Manage service access, migrations, retention jobs, backups and recovery. |

## System Requirements

### 1. Browse by stop and destination

The corridor map and directional feed open the same stop summary. Show **bus activity**, **seat availability** and **queue** separately. A guest can browse either direction regardless of where they are. Use destination names in both clients. Direction is required on every report because opposite boarding areas can be close together.

### 2. Submit a current observation

A signed-in contributor selects a named pilot stop and destination. For a report or confirmation, request one foreground location check. Accept the selected stop when the device can establish it is **within 150 m** of its configured boarding location. If zones overlap, require an explicit stop and destination choice. If permission is denied or the check fails, explain the reason and keep browsing available.

| Field | Values the contributor can report | Expires after service acceptance |
|---|---|---|
| Bus activity | Approaching, boarding, departed | 15 minutes |
| Seat availability | Spacious, standing room, full. Optional on a bus report. | 15 minutes |
| Queue at the stop | Light, moderate, heavy | 20 minutes |

Accept reports and confirmations while online. Use the service acceptance time and enforce **one submission per account every two minutes** across Web and Android. A bus report with an optional seat estimate is one submission. Confirmations share the cooldown so switching clients or tapping *Still accurate* cannot bypass it.

### 3. Publish only what other contributors corroborate

For each **stop, direction and field**, count the latest unexpired observation per account. A confirmation supports only the field value the contributor personally observed. It gets its own expiry and cannot extend another person’s observation.

| Current evidence for a field | What everyone sees |
|---|---|
| No value has support from two distinct accounts | **No recent confirmed report**. Zero reports and a lone report look identical. A second rider can independently submit what they see. |
| One value has support from at least two distinct accounts | **Community-confirmed**, the value, and the age of the latest supporting observation. |
| Two or more different values each qualify | **Reports disagree**. Keep the other fields independently readable. |

Recompute on submission, confirmation, removal and expiry. For example, if two riders report **Boarding** and only one says **Full**, publish **Boarding** and keep the seat field at **No recent confirmed report**. When the first rider’s bus observation expires, withdraw **Boarding** unless two other current observations still support it.

### 4. Handle disconnection and corrections

Cache the corridor and stop list on both platforms. Offline, show the directory and an **Offline** label with the last refresh time. Hide live values and refresh on reconnect before accepting a new submission. Discard unsent observations so an old sighting cannot acquire a fresh timestamp.

A signed-in reader may flag a published field and select a reason, such as wrong direction or suspected abuse. A flag opens a review. A moderator may dismiss it, remove inaccurate evidence, or record an internal hit and restrict posting after verifying abuse. Flag volume alone cannot issue a hit or suspend an account. Removal updates the public result under the same publication rule.

## Required Solution Layers

- **Location and identity.** Explain foreground location use before asking permission. Reduce the check to a configured stop and discard raw coordinates immediately. Keep coordinates, contributor identifiers and individual observations out of public responses, routine logs and analytics. Enforce roles, distinct-account counts and cooldowns in the service. Browsing remains available after location permission is withdrawn.
- **Retention and recovery.** Hide expired evidence immediately. Purge expired or removed observations and their account links within five minutes. Restrict report-level identity lookup to active moderation. Keep any sanction’s reason and duration separate from stop and direction. Exclude transient reports and identity links from retained backups and verify that restoring service cannot republish expired results. Review the implemented flows against the Data Privacy Act requirement before public launch.
- **Pilot data.** Retain aggregate counts needed to assess coverage and usefulness. Keep route and PUV type configurable, with Metro Bus as the only active type. Defer historical ML datasets, model training, predictions and data resale. If later approved, historical summaries need a separate privacy review and a minimum of three distinct contributors **per retained measure** within each bucket. Bus reports without seat observations give no support to a seat statistic.

## MVP Features and Access

| Launch feature | Access | Acceptance check |
|---|---|---|
| 1. Browse the map and feed | A–E | A guest selects either destination without granting location access. Both clients show the same stop result and withdraw stale values. |
| 2. Report bus activity, seats or queues | A–D | A contributor within the pilot radius can report. Repeating a report from a second client cannot supply the second account. |
| 3. Confirm, flag and moderate | A–D contribute. A–C review. | Two matching bus reports can publish activity while seats remain unconfirmed. Removing one of exactly two supporters withdraws the value. |
| 4. Operate the pilot | A–B maintain settings and review aggregate results. A operates purge and recovery. | The team can correct a boarding location, verify expiry and purge, and restore service without restoring individual travel records. |

## Notes — field pilot and expansion decision

Before launch, Astrolab and participating conductors select a small set of named stops and travel periods with coverage in both directions. Walk the boarding areas with representative phones to test the 150 m radius, especially across the highway. Rehearse a weak-connection session and check whether a **Boarding** sighting near the end of its 15-minute window still helps a waiting rider.

Run a **two-week pilot** with at least **20 sampled stop checks per direction**. For each direction, tally how many checks show a current, community-confirmed bus activity and how many riders who see one say it helped them decide. Keep aggregate tallies without identities or itineraries. Use these initial expansion criteria:

- **Coverage:** at least **60%** of all sampled checks in each direction show a confirmed bus activity.
- **Usefulness:** at least **70%** of sampled checks that showed a confirmed bus activity in each direction yield a rider response that it helped.
- **Privacy:** resolve any confirmed location exposure before expanding.

If coverage is low, adjust contributor participation or the selected stops and repeat the pilot. Consider highway segments only if field evidence shows stop sightings arrive too late to help. Additional PUV types, push notifications, hardware tracking, fares, chat, public reputation and rewards stay outside Phase 1.
