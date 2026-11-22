# 05 — Debugging playbook

**Purpose:** Distinguish checkout and history problems before looking for runtime logs.

**Confidence note:** Verified against Business Logic v1.0 and the local pre-commit snapshot on 2026-11-22 (source fingerprints in 00). The code wins (see 16).

There are no application log paths, CI logs, runtime error codes or telemetry settings in the local files. The available diagnostic record is the child repository's Git state and the specs. No frequency data exists. The table gives the locally observed cause first.

| Exact symptom or fragment | Observed cause | Diagnostic shortcut |
|---|---|---|
| `fatal: not a git repository (or any of the parent directories): .git` | Git ran in the ecosystem root. | Enter the owning child and run `git rev-parse --show-toplevel`. See 06 #1. |
| `fatal: your current branch 'main' does not have any commits yet` | The child has an unborn branch. | Compare `git log --all --oneline` with `git status --short --branch`. Untracked specs are readable even with empty history. |
| `## No commits yet on main...origin/main [gone]` | No local commit or resolvable local upstream ref. | Inspect `git branch -avv` and `git tag --list`. This output alone cannot establish the state of a remote server. |
| `fatal: detected dubious ownership in repository at` | Git's ownership check stopped an invocation under the sandbox account. | Check which account owns the directory and retry from the intended child in its normal working context. The audit could read history there. |
| A guide describes a tag but `git tag --list` prints nothing | The guide includes template tables and retrospective prose. | Read the actual product table, then inspect local refs. See 06 #2 before assigning a release date. |

From a child directory, `rg --files --hidden --no-ignore -g '!**/.git/**'` shows even untracked or ignored project files. Use it when a manifest seems to be missing. From specs, `rg -n 'Google Sign-In|retention|aggregation' business-logic-v1.0.md` locates the actual requirement. *Miss →* filename or example searches can be mistaken for proof that a feature runs.
