---
name: validate-pr
description: >
  Prepare a ZeroTrustAssessment pull request for local validation from any branch.
  Stashes local changes, checks out the PR, imports the module, then hands the user
  a copy-pasteable Connect-ZtAssessment + Invoke-ZtAssessment block to run in their
  own terminal (interactive auth does not work reliably under Copilot). After the
  user confirms the run is done, restores the original branch and pops the stash.
  WHEN: "validate PR", "validate a PR", "check this PR", "test this pull request",
  "review PR <number>", "prep for PR validation", "smoke test PR", "PR validation",
  "validate pull request", "set up to run ZT assessment against PR",
  "cleanup after PR validation", "undo PR checkout".
allowed-tools: shell
---

# ZeroTrustAssessment PR Validation

You are a procedural agent that prepares a ZeroTrustAssessment pull request for
local validation, then cleans up afterwards.

This skill must work **regardless of which branch the user is currently on**, including
detached HEAD, feature branches, and dirty working trees. Always inspect repo state
**before** changing branches, and stop with a clear message if it is unsafe to proceed.

## Why this skill does not run `Connect-ZtAssessment` / `Invoke-ZtAssessment` itself

`Connect-ZtAssessment` defaults to an interactive browser popup, which fails under the
Copilot terminal (no UI). The cmdlet does support `-UseDeviceCode`, but the
long-running `Invoke-ZtAssessment` that follows will hold the terminal for the rest of
the assessment and can stall on any mid-run prompt. To keep automation reliable, this
skill **stops after `Import-Module`** and prints the exact commands for the user to
run in their own terminal, then waits for a "done" / "cleanup" signal.

## Prerequisites (verify silently before starting)

Run these checks in order. If any fail, stop and report the exact remediation:

1. `gh --version` — GitHub CLI is required for `gh pr checkout`. If missing, instruct
   the user to install it (`winget install GitHub.cli`) and stop.
2. `git rev-parse --show-toplevel` — confirms we are inside the repo and gives the
   repo root. Use this value as `$RepoRoot` everywhere below; do not assume CWD.
3. `git status --porcelain` — detects uncommitted changes. If non-empty, tell the
   user what is dirty and ask whether to:
     - stash (`git stash push -u -m "validate-pr auto-stash"`), or
     - abort.
   Never discard their work.

## Required Inputs (ask once, up front, in a single message)

Collect all of these in one prompt so the user can fire-and-forget:

| Input | Required | Default | Notes |
|-------|----------|---------|-------|
| **PR number or URL** | Yes | — | Accept `123`, `#123`, or full GitHub URL. |
| **TenantId** | Yes | — | GUID or domain (e.g. `contoso.onmicrosoft.com`). Used only when composing the hand-off block; the skill never calls `Connect-ZtAssessment` itself. |
| **Resume** | No | `$false` (omit switch) | Reuses prior export data. |
| **Path** | No | omit (lets cmdlet default to `./ZeroTrustReport`) | Output folder for the report. |
| **Pillar** | No | omit (defaults to `All`) | Single value from: `All`, `Identity`, `Devices`, `Network`, `Data`, `Infrastructure`, `SecOps`, `AI`. The cmdlet parameter is `-Pillar` (singular). Note that `Infrastructure`, `SecOps`, and `AI` require also adding `-Preview` — surface this to the user when they pick one. |
| **Tests** | No | omit (runs every test) | Comma-separated list of test IDs (e.g. `35001,35003`). |

> Do **not** prompt for optional values one-by-one. Present the full list with defaults
> and let the user respond with only the overrides they care about.

## Execution Plan — Phase A: Setup (runs automatically)

After inputs are confirmed, execute the following in order. Run each step in the
terminal, surface its output, and stop on the first failure.

### Step 1 — Capture starting state

Before touching anything, remember where the user came from so cleanup can restore it:

```powershell
$StartingBranch = git -C "$RepoRoot" rev-parse --abbrev-ref HEAD
$StartingSha    = git -C "$RepoRoot" rev-parse HEAD          # fallback for detached HEAD
```

If `$StartingBranch` is `HEAD`, the user was in detached HEAD — record `$StartingSha`
for cleanup instead and mention this fact to the user.

### Step 2 — Refresh remote refs (branch-agnostic)

```powershell
git -C "$RepoRoot" fetch --all --prune --tags
```

Use `git fetch` rather than `git pull` because the user may be on an unrelated branch
or detached HEAD. Fetching never modifies the working tree.

### Step 3 — Checkout the PR

```powershell
gh pr checkout <PR-number> --repo (gh repo view --json nameWithOwner -q .nameWithOwner)
```

Run this from `$RepoRoot`. `gh pr checkout` handles fork remotes, branch creation,
and upstream tracking. If the user gave a URL, extract the number.

> Heads-up: `gh pr checkout` may surface tracked-file changes the PR makes to files you
> already had open (e.g. `.vscode/settings.json`). That is normal — those are PR
> contents, not the user's work. Mention it in the report but do not stash again.

### Step 4 — Sync the PR branch

```powershell
git -C "$RepoRoot" pull --ff-only
```

Use `--ff-only` so a divergent PR branch fails loudly instead of producing a merge
commit. If it fails, report the cause and stop — do not auto-rebase.

### Step 5 — Show what is being validated

Print, for the user's audit log:

- Current branch: `git -C "$RepoRoot" rev-parse --abbrev-ref HEAD`
- HEAD SHA: `git -C "$RepoRoot" rev-parse --short HEAD`
- PR title and author (from `gh pr view <number> --json title,author -q '...'`).

### Step 6 — Import the module fresh

```powershell
Import-Module "$RepoRoot\src\powershell\ZeroTrustAssessment.psd1" -Force
```

`-Force` reloads if a prior version is already in the session. If this fails with a
language-mode / signing error, surface the message verbatim — do **not** add
`-IgnoreLanguageMode` or any other flag without explicit user permission.

Setup ends here. **Do not call `Connect-ZtAssessment` or `Invoke-ZtAssessment` from
the Copilot terminal.**

## Execution Plan — Phase B: Hand off to user

Compose the ready-to-paste block below with the user's actual values, print it inside
a fenced code block, and tell the user:

> "Paste this into your own pwsh terminal in the repo root. When it finishes (or you
> want to abort), tell me **cleanup** and I'll restore your branch and stash."

Build the splat first so omitted defaults stay omitted (cmdlet defaults must apply):

```powershell
$invokeArgs = @{}
if ($Resume) { $invokeArgs['Resume']  = $true }
if ($Path)   { $invokeArgs['Path']    = $Path }
if ($Pillar) { $invokeArgs['Pillar']  = $Pillar }
if ($Tests)  { $invokeArgs['Tests']   = ($Tests -split ',').Trim() }
# Add -Preview only when Pillar is Infrastructure, SecOps, or AI.
if ($Pillar -in 'Infrastructure','SecOps','AI') { $invokeArgs['Preview'] = $true }
```

The hand-off block printed to the user looks like this (substitute real values):

```powershell
# Run in your own pwsh terminal, from the repo root:
Connect-ZtAssessment -TenantId '<TenantId>' -UseDeviceCode
Invoke-ZtAssessment @invokeArgs
```

`-UseDeviceCode` is the right default here: it prints a code + URL the user opens in
their own browser instead of trying to launch one from the agent context.

## Execution Plan — Phase C: Cleanup (on user signal)

Trigger when the user says any of: `cleanup`, `done`, `restore`, `revert`, `unstash`,
`I'm done`, `validation done`.

### Step C1 — Discard PR-side tracked changes that would block the branch switch

If `git status --porcelain` shows tracked files modified, those are PR contents the
user did not author (we never run editors during Phase A). Check against the stash
first, then discard:

```powershell
git -C "$RepoRoot" status --porcelain
# For each modified file, if it differs from HEAD because of the PR (not the user),
# discard with: git -C "$RepoRoot" checkout -- <path>
```

If you are not 100% sure a modification came from the PR, **stop and ask**. Never
blanket-discard with `git checkout -- .` or `git reset --hard`.

### Step C2 — Return to the starting ref

```powershell
git -C "$RepoRoot" checkout $StartingBranch   # or $StartingSha for detached HEAD
```

### Step C3 — Pop the stash (if Phase A created one)

```powershell
git -C "$RepoRoot" stash pop
```

If `stash pop` reports a conflict on an untracked file that already exists at the
same path, diff the on-disk file vs the stashed copy before resolving. If they are
the same content, drop the stash explicitly:

```powershell
git -C "$RepoRoot" stash drop 'stash@{0}'
```

### Step C4 — Confirm clean state

Report final `git status` and `git stash list` to the user.

## Hard Rules

- Never run `git reset --hard`, `git clean -fdx`, `git checkout -- .`, or any other
  blanket-destructive command. Always operate on specific files and ask when unsure.
- Never `git pull` while on the user's starting branch in Phase A — fetch only. The
  only `pull --ff-only` happens *after* `gh pr checkout` has moved HEAD to the PR.
- Never call `Connect-ZtAssessment` or `Invoke-ZtAssessment` yourself. Auth requires
  a real user terminal. Phase B is hand-off only.
- Never invent test IDs, pillars, or tenant IDs. If the user's input is malformed,
  re-ask for that single field.
- Never substitute `-Pillars` (plural) — the real parameter is `-Pillar`. Reject
  multiple pillar values with a short message pointing the user to `-Tests` if they
  want a narrower scope.
- Always remember to add `-Preview` to the hand-off block when Pillar is one of
  `Infrastructure`, `SecOps`, `AI` — those pillars are gated on it.
- Phase C is **not optional**. Always offer it after Phase B, and always run it when
  the user signals done.

## Final Report

After Phase A, summarize:

1. Starting branch / SHA captured for cleanup.
2. Whether a stash was created (and its name if so).
3. PR number, title, branch, HEAD SHA now checked out.
4. The hand-off block (with real values inlined) inside a fenced `powershell` code block.
5. A reminder: "Tell me **cleanup** when you're done and I'll restore your branch + stash."

After Phase C, summarize:

1. Branch restored (and SHA).
2. Stash status (popped, dropped as duplicate, or still present with reason).
3. Final `git status` output.
