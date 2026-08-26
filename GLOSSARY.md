# Glossary

Every term from the Linux Learning Path, in one place for quick review.
Organized by the week it first shows up in — skim a section after
finishing that week, or use this for a refresher before starting the
next one.

## Week 1 — Shell Foundations

- **Shell** — the program that reads what you type and runs commands
  (`bash` is the one you're using).
- **`pwd`** — print working directory: where you currently are.
- **`man`** — manual pages, the built-in reference for most commands.
- **Permissions** — rules on a file controlling who can read/write/
  execute it, shown by `ls -l` as a 10-character string.
- **`chmod`** — change a file's permissions.
- **`chown`** — change a file's owner.
- **Root** — the all-powerful admin account (uid 0); ignores permission
  checks entirely.

## Week 2 — Multi-User Linux

- **UID / GID** — numeric IDs identifying a user / group under the
  hood; usernames are just labels for these numbers.
- **`/etc/passwd`** — the file listing every user account on the
  system.
- **`/etc/group`** — the file listing every group and its members.
- **Process** — a single running program, identified by a PID.
- **PID** — process ID, a unique number for each running process.
- **Signal** — a message sent to a process (`kill` sends `SIGTERM` by
  default, `-9` sends `SIGKILL`).
- **Package manager** — the tool (`apt` on Ubuntu) that installs,
  updates, and removes software in a tracked, repeatable way.

## Week 3 — Text Wrangling & Automation

- **Pipe (`|`)** — sends one command's output directly into the next
  command's input.
- **Redirection (`>`, `>>`)** — sends a command's output to a file
  instead of the screen.
- **Regex (regular expression)** — a pattern language for matching
  text, used by `grep`, `sed`, and many other tools.
- **Anchor (`^`, `$`)** — regex symbols meaning "start of line" / "end
  of line."
- **Shebang (`#!/bin/bash`)** — the first line of a script, telling the
  OS which interpreter should run it.
- **Cron** — the built-in Linux scheduler for running commands
  automatically at set times/intervals.
- **Crontab** — the file (edited via the `crontab` command) listing a
  user's scheduled cron jobs.

## Week 4 — Services

- **systemd** — the process manager that starts, stops, and supervises
  background services on modern Linux.
- **Service / unit** — a single thing systemd manages (e.g. `docker`,
  `nginx`), described by a unit file.
- **Enabled** — a service is set to start automatically on boot.
- **Active** — a service is currently running right now (independent of
  "enabled").
- **`journalctl`** — systemd's built-in log viewer.
- **Unit file** — the config file (`.service`) describing how systemd
  should run a service.

## Week 5 — Networking

- **IP address** — a numeric address identifying a machine on a
  network.
- **Private vs public IP** — a private IP (e.g. `10.0.0.x`) is only
  reachable inside a local network; a public IP is reachable from the
  internet. Cloud providers often translate one to the other.
- **Port** — a numbered "channel" a program listens on (e.g. 22 for
  SSH, 80 for HTTP).
- **DNS** — the system that turns domain names (e.g. `example.com`)
  into IP addresses.
- **Firewall** — software that controls what network traffic is
  allowed in or out of a machine.
- **`ufw`** — Ubuntu's simplified frontend over the kernel's real
  firewall.

## Week 6 — Docker Deep Dive

- **Image** — a packaged, reusable template for creating containers
  (e.g. `ubuntu`, `nginx`).
- **Container** — a running (or stopped) instance of an image —
  lightweight, isolated, and normally disposable.
- **`Dockerfile`** — a recipe describing how to build a custom image.
- **Volume** — a storage location managed by Docker that survives even
  after the container using it is deleted.
- **Docker network** — a virtual network letting containers reach each
  other by name.
- **Docker Compose** — a tool for defining and running multiple
  containers together as one application, described in a
  `docker-compose.yml` file.

## Week 7 — Security

- **SSH key pair** — a private key (kept secret, never shared) and a
  matching public key (shared freely, placed in `authorized_keys`) used
  to prove identity without a password.
- **`authorized_keys`** — the file listing which public keys are
  allowed to log in as a given user.
- **Brute force (attack)** — repeatedly guessing passwords/keys until
  one works; the reason key-only auth and fail2ban both matter.
- **fail2ban** — software that watches logs for repeated failed login
  attempts and temporarily bans the offending IP.
- **`/var/log/auth.log`** — the log file recording authentication
  attempts (successful and failed) on the system.

## Week 8 — Guru Capstones

- **Deployment** — the process of getting software running and
  reachable on a real server, for real use.
- **VPN (Virtual Private Network)** — a way of routing traffic through
  an encrypted tunnel to another machine, used for privacy or to
  connect to a private network remotely.
- **WireGuard** — a modern, simple, fast VPN protocol built directly
  into the Linux kernel.
- **Monitoring / health check** — automated, repeated checks that a
  service is actually working, often paired with automatic recovery
  and alerting.
