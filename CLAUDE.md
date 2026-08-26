# CLAUDE.md

Guidance for Claude Code (or any engineer/agent) working in this repo.

## What this is

A personal Linux learning/practice sandbox for the user (Daniel O'Leary) —
**explicitly unrelated to the `self-destruct-handover` project** (a
separate zero-knowledge secret-sharing product in a different repo,
`c:\Scripts\self-destruct-handover`). Kept in its own directory and its
own chat on purpose, so the two don't get tangled — different purpose,
different risk profile, different infrastructure.

**Goal:** an "online" (not local-only), persistent Linux box the user can
SSH into from anywhere to practice commands, break things on purpose, and
learn — with an easy way to reset back to a clean state when needed.
Genuinely just for learning; not a product, not for other users.

Secondary, exploratory interest: **self-hosting a VPN** (e.g. WireGuard)
as a follow-on learning project now that the sandbox itself is up and
familiar. Not committed to yet — treat as something to explain and maybe
try, not something to build unprompted.

For hands-on usage instructions (SSH, Docker reset workflow, etc.), see
[USE_ME.md](USE_ME.md). For the structured 8-week, 24-day learning
curriculum, see [LEARNING.md](LEARNING.md) — pace is explicitly
open-ended (the user is fine with this taking months; "1 day a week"
is a stated acceptable pace, not a fallback). [GLOSSARY.md](GLOSSARY.md)
has every term by week. [HANDOVER.md](HANDOVER.md) is the
disaster-recovery runbook — read that first if the instance is ever
gone/reclaimed/replaced. [provision.sh](provision.sh) is the idempotent
setup script referenced from HANDOVER.md.

The `training/` directory (local copy in this repo, deployed to
`~/training/` on the instance itself) holds:
- `check_dayN.sh` — one self-check script per host-verifiable day,
  confirms that day's exercises actually worked against real system
  state (not just "did you run the command")
- `course.sh` — progress tracker: `status` (planner — progress bar +
  streak counter), `done <N>` / `undone <N>` (marker), `test <N>`
  (tester), `certificate` (prints a completion certificate once all 24
  are done). A login banner (added to `~/.bashrc` on the instance)
  shows `course.sh next` automatically on every SSH login.

When the curriculum changes (days added/renumbered/retitled), keep
`course.sh`'s `TITLES` array in sync, update `provision.sh`/HANDOVER.md
if the setup steps change, and re-deploy the whole `training/`
directory to the instance (`scp` the changed files, then `chmod +x`).

This repo is under local git (no remote) — commit changes as they're
made so nothing here is ever lost.

## Current state

- **Host:** Oracle Cloud "Always Free" tier — confirmed free, no charge
  concern. Known risk: Oracle has a history of reclaiming idle Always
  Free instances; mitigation is logging in occasionally. Fallback if
  ever reclaimed: a small Netcup VPS (~€1.90/mo), same process already
  proven for the self-destruct-handover project's production server.
- **The instance:** hostname `linux-sandbox`, IP `143.47.240.110`,
  Ubuntu 24.04. This was an existing idle Oracle instance (originally
  `instance-20250913-2240`, created 2025-09-13 for an earlier unrelated
  project) that got repurposed as the sandbox rather than creating a
  new one, to stay within Always Free instance-count limits. Fully
  updated and rebooted onto the current kernel as of 2026-08-26.
  - Oracle Cloud **console display name** still shows the old
    `instance-20250913-2240` — cosmetic only, change it manually via
    the OCI web console if wanted (needs console/API access this chat
    doesn't have).
- **SSH access:** dedicated key pair at `~/.ssh/sandbox_oracle` /
  `~/.ssh/sandbox_oracle.pub`, not shared with any other project.
  ```
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqMO/ahf5t3LJN5T5Y/G8etcke5Xd9vCUmWE2g442mH linux-sandbox
  ```
  Already appended to the instance's `authorized_keys`. The original
  Oracle-default RSA key (`D:\Dropbox\MobaXterm\ssh-key-2025-08-08.key`,
  used by MobaXterm's saved session) still works too, left in place as
  a fallback.
- **Reset strategy:** Docker is installed and working (`ubuntu` user is
  in the `docker` group, no `sudo` needed) for fast, cheap resets of
  individual experiments — see USE_ME.md for the actual commands. Full
  OS reinstall via the OCI console's one-click feature remains the
  fallback for a truly clean slate.
- **Quality-of-life:** `neofetch` runs automatically on every login.

### Another instance exists on the same Oracle account — leave it alone

`vpn-server` (130.162.170.158) is a **separate, unrelated, still-in-use**
personal box from an earlier project — running OpenVPN, Tailscale, and
xrdp. It predates this sandbox project and shares the same Oracle
account and default SSH key, which is why it may show up in MobaXterm's
saved sessions alongside the sandbox. Not part of this repo's scope;
don't modify it.

### Outstanding / not started

- WireGuard / self-hosted VPN exploration — the secondary interest
  above, not begun yet.
- Oracle console display name rename — cosmetic, low priority.

## Working method (this worked well — keep doing it)

- **Verify, don't assume.** Before recommending a next step, check
  actual state where possible (e.g. test port reachability, confirm DNS
  resolution) rather than trusting a UI label or assuming success.
- **One step at a time, with confirmation.** For anything destructive or
  hard to reverse (firewall changes, disabling access, deleting
  instances), explain the risk plainly, keep a fallback session/access
  path open until a change is proven to work, and ask before proceeding
  if there's real ambiguity.
- **Explain the why, not just the how.** The user explicitly wants to
  learn, not just copy-paste commands — plain-language reasoning
  alongside every command is the point, not an add-on.
- **Never ask for passwords/secrets in chat.** Guide the user to enter
  credentials themselves in their own terminal/browser; only IPs,
  usernames, and public keys are fine to share here.
- **Direct SSH access is fine.** The user is comfortable with Claude
  running SSH commands directly against the box (`ssh -i
  ~/.ssh/sandbox_oracle ubuntu@143.47.240.110 ...`) rather than a
  paste-output-back loop, for diagnostics and routine maintenance.
  Still confirm before genuinely destructive/hard-to-reverse actions.
- **Keep this file updated** as decisions get made and infrastructure
  changes — it's what makes picking this back up in a new session
  painless. Prefer editing this "Current state" section over appending
  a new dated journal entry each time; keep it a snapshot, not a log.

## Explicitly out of scope for this repo

- Anything about the `self-destruct` product itself — that lives entirely
  in `c:\Scripts\self-destruct-handover`.
- Anything about the tube-map site(s) (`londontubemap.online` and the
  various `TubeMap*`/`tube-app` folders under `c:\Scripts\`) — separate
  project, separate history, not tracked here.
- `vpn-server` (130.162.170.158) — separate pre-existing personal box,
  see above.
