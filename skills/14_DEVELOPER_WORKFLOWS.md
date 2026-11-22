# 14 — Developer workflows

**Purpose:** Use the available files to orient yourself, change a requirement or prepare review evidence.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

### 1. Set up a local review
1. From `pasada-ecosystem`, run `Get-ChildItem -Directory -Name`, then enter the relevant child, e.g. `Set-Location pasada-specs`. The parent cannot report child history (06 #1).
2. Run `git status --short --branch`, `git log --all --oneline`, `git tag --list` and `rg --files --hidden --no-ignore -g '!**/.git/**'`. Include untracked files or the three existing specs disappear from the review.
3. Read the business brief, the relevant sections of the Git guide and 01. There are currently no verified package-install or service-start steps.
4. add what surprised you to `INBOX.md`

### 2. Change a role or shared feature
1. Name the actor, feature and intended action in the business brief. Review **User Levels** and every matching **MVP Features and Access** row together (04 #1).
2. Check whether the change involves sign-in, location, aggregation, retention or consent. Record the effect where the API and data design will consume it (04 #6).
3. Walk a permitted role and a denied role through the new requirement. Keep any runtime claim open until implementation evidence exists (11).
4. add what surprised you to `INBOX.md`

### 3. Review a candidate or spec baseline
1. Work in the owning product repository and compare its tags to the product table (06 #2). Check the actual short code and candidate branch (04 #2–4).
2. Follow 10's stage gates. For a spec baseline, identify the reviewed revision, stakeholder decision and implementation handoff. For a binary, identify the exact published artifact and approval.
3. Check that the candidate being delivered is the one reviewers assessed. *Miss →* a rebuild or a later edit can invalidate their approval.
4. add what surprised you to `INBOX.md`

### 4. Prepare the environmental scan
1. Read the latest business brief and identify the study's focal issue. The initial brief still has placeholder descriptions. Document the focus before gathering findings or the sources may support the wrong study.
2. Follow the source-verification and scoring instructions in `pasada-specs/sense-making.md`. Check the field order, quotas, limits and quoting (04 #5, 11).
3. The specified output path is `pasada-specs/planning/sense-making.csv`. A rough lead with an unverified source belongs in review notes until verified.
4. add what surprised you to `INBOX.md`
