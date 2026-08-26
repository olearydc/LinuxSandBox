# Handover / Disaster-Recovery Doc

Everything needed to rebuild this project from nothing — in case the
Oracle instance gets reclaimed, is accidentally destroyed, or you're
picking this up on a new machine. Written so a fresh Claude Code
session (or a human with a terminal) can follow it without any prior
context.

## What this project is, in one paragraph

A personal Linux practice sandbox on Oracle Cloud's Always Free tier,
with Docker for fast disposable resets, a full 29-day self-paced
training course, and a progress tracker — all documented in this repo
(`c:\Scripts\linux-sandbox`). Full background and decisions:
[CLAUDE.md](CLAUDE.md).

## Every file in this repo, and what it's for

| File | Purpose |
|---|---|
| `CLAUDE.md` | Full project history, decisions, current state — the source of truth |
| `USE_ME.md` | User-facing quick reference: connecting, Docker reset patterns, course tracker commands |
| `LEARNING.md` | The 29-day training curriculum itself |
| `HANDOVER.md` | This file |
| `provision.sh` | Idempotent script that sets up a host from scratch (or repairs an existing one) — update, hostname, Docker, neofetch, login banner |
| `training/course.sh` | Progress tracker (planner/marker/tester) — lives on the instance at `~/training/course.sh` |
| `training/check_dayN.sh` | One self-check script per host-verifiable curriculum day — live on the instance at `~/training/check_dayN.sh` |
| `.gitattributes` | Forces LF line endings on `.sh` files so they don't break when checked out on Windows |

This repo is under local git (`git log` for history) — no remote, just
a safety net so nothing here gets silently lost or overwritten.

## Current live instance (as of last update — verify, don't assume it's still true)

- Hostname: `linux-sandbox`, public IP `143.47.240.110`, Ubuntu 24.04
- This *was* a pre-existing idle Oracle instance (`instance-20250913-2240`)
  repurposed for this project rather than creating a new one — see
  CLAUDE.md's "Current state" section for the full story
- SSH: `ssh -i ~/.ssh/sandbox_oracle ubuntu@143.47.240.110`
- **A separate, unrelated box (`vpn-server`, 130.162.170.158) exists on
  the same Oracle account — do not touch it, it's someone else's
  earlier project still in active use.** See CLAUDE.md for details.

## Scenario: the instance is gone / reclaimed / you need a fresh one

1. **Create a new Oracle Cloud instance.**
   - Menu → Compute → Instances → Create Instance
   - Shape: must say **"Always Free eligible"** explicitly — verify
     this in the UI, don't assume. `VM.Standard.E2.1.Micro` (AMD) or
     `VM.Standard.A1.Flex` (ARM, sized within free limits) are the
     known-good options.
   - Image: Ubuntu 24.04 LTS
   - SSH key: paste the `sandbox_oracle` **public** key (below) via
     "Paste public keys"
   - If Always Free capacity is exhausted or Oracle becomes
     unworkable: documented fallback is a small Netcup VPS
     (~€1.90/mo), same process already proven for the
     `self-destruct-handover` project's production server.

2. **Confirm the SSH key exists locally.** It should already be at:
   ```
   ~/.ssh/sandbox_oracle
   ~/.ssh/sandbox_oracle.pub
   ```
   Public key value (also embedded in CLAUDE.md):
   ```
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqMO/ahf5t3LJN5T5Y/G8etcke5Xd9vCUmWE2g442mH linux-sandbox
   ```
   If it's missing, generate a fresh one (`ssh-keygen -t ed25519 -f
   ~/.ssh/sandbox_oracle -C linux-sandbox`) and update this doc and
   CLAUDE.md with the new public key.

3. **Run the provisioning script** against the new instance's IP:
   ```bash
   ssh -i ~/.ssh/sandbox_oracle ubuntu@<NEW_IP> 'bash -s' < provision.sh
   ```
   This handles: system update, hostname → `linux-sandbox`, neofetch on
   login, Docker CE install + docker group, `~/training` directory, and
   the login progress banner. It's idempotent — safe to re-run on an
   existing box too if something's misconfigured.

4. **Deploy the training toolkit:**
   ```bash
   scp -i ~/.ssh/sandbox_oracle training/*.sh ubuntu@<NEW_IP>:~/training/
   ssh -i ~/.ssh/sandbox_oracle ubuntu@<NEW_IP> 'chmod +x ~/training/*.sh'
   ```

5. **If the kernel was updated in step 3**, reboot and confirm it
   comes back:
   ```bash
   ssh -i ~/.ssh/sandbox_oracle ubuntu@<NEW_IP> 'sudo reboot'
   # wait ~30-60s, then:
   ssh -i ~/.ssh/sandbox_oracle ubuntu@<NEW_IP> 'uptime -s && uname -r'
   ```

6. **Update CLAUDE.md** with the new IP and any new decisions, and
   commit the change (`git add -A && git commit`).

## Scenario: you just want to verify the current box matches this doc

```bash
ssh -i ~/.ssh/sandbox_oracle ubuntu@143.47.240.110 '
hostname
docker --version
groups
ls ~/training/
bash ~/training/course.sh status | tail -2
'
```
Compare against: hostname `linux-sandbox`, Docker installed, `docker`
in your groups list, all the `check_dayN.sh` + `course.sh` files
present.

## Scenario: your progress data (course.sh tracker) got wiped

Progress lives in a single plain-text file on the instance:
`~/training/progress.txt` — one completed day number per line. There's
no backup of this by design (it's meant to be low-stakes); if it's
gone, just re-mark days as done with `~/training/course.sh done <N>`
for whichever days you've actually completed. Nothing else depends on
it.

## Known risks worth remembering

- Oracle can reclaim idle Always Free instances — log in occasionally
  (working through the course does this naturally)
- The `docker` group grants root-equivalent host access to that user —
  fine for a single-user sandbox, not a real security boundary
- `vpn-server` on the same account is out of scope and must not be
  modified by anything done here
