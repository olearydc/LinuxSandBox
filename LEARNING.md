# Linux Learning Path — Zero to Guru

A 9-week, 32-day training course for the `linux-sandbox` box. No prior
Linux knowledge assumed beyond what you've already done in this
project (SSH in, run `docker run`). Weeks 1-8 build the foundation on
this box; Week 9 sends you out to fully complete three respected
external platforms (OverTheWire Bandit, TryHackMe, KodeKloud) using
nothing but what you've already learned — the real proof it stuck.

**How each day works:**
- **Do this** — the exact command(s) to type
- **You should see** — a realistic example of the output, so you can
  tell if it worked (your exact numbers/names will differ — the
  *shape* of the output is what matters)
- **What's happening / why** — the reasoning, not just the syntax
- **🌍 In the real world** — how this actually shows up in real
  incidents and real practice, not just theory
- **Check yourself** — a question to answer in your own words *before*
  moving on
- **Self-check** — where a script on the instance can verify your work
  against real system state

**Where to practice:** unless marked **(host)**, work inside a
disposable container: `docker run -it --rm ubuntu bash` (see
[USE_ME.md](USE_ME.md)). **(host)** days need the real machine —
users, systemd, cron, git history, and real networking don't exist in
a bare container.

**Pace:** there is no deadline here. ~3 days a week gets you through
this in about 9-10 weeks, but if that feels rushed, go slower — 1 day a
week is a perfectly good pace and just means several months, which is
fine. Any day with more than one exercise can be split across two
sessions — do the first exercise, stop, come back later for the rest of
that same day. Understanding beats speed every time; the self-checks
and weekly reviews aren't graded on how fast you got there. Come back
anytime and say "day N" — I'll walk through it live, answer questions,
and check your work.

---

# Week 1 — Shell Foundations

## Day 1 — Finding your way around

**Objective:** move confidently and know how to get help instead of
guessing.

**Do this:**
```bash
pwd
ls -la
man ls        # space to page, q to quit
whoami
id
history
```
**You should see:** your current directory, a detailed file listing
(including hidden dotfiles), a full manual page, your username, your
user/group IDs, and a numbered list of everything you've typed.

**What's happening / why:** `pwd`/`ls` are your eyes in a world with no
file explorer window. `man` is the built-in reference for nearly every
command — check here before searching online. `history` plus the
**up-arrow** key means you almost never retype a command.

**🌍 In the real world:** `man` pages have existed since Unix's first
release in 1971 — even senior engineers reach for `man <cmd>` or a
cheat-sheet constantly. Nobody memorizes every flag; knowing *how to
look it up fast* is the actual skill.

**Check yourself:** why does `.bashrc` show up in `ls -la` but not
plain `ls`?

---

## Day 2 — Files, permissions, ownership

**Objective:** understand exactly why `Permission denied` happens.

**Do this:**
```bash
touch file.txt
ls -l file.txt
chmod 000 file.txt
ls -l file.txt
useradd -m testuser
su testuser -c "cat file.txt"
```
**You should see:** `-rw-r--r--` initially, then `----------` after
`chmod 000`, then `Permission denied` when `testuser` tries to read it
(root ignores permission bits — that's *why* you need a second user to
actually see a denial).

**What's happening / why:** `ls -l`'s 10-character string is
`[type][owner][group][other]`, each triplet read/write/execute.
`chmod` numbers are `read(4)+write(2)+execute(1)` added per triplet —
`644` = owner read+write, everyone else read-only.

**🌍 In the real world:** misconfigured permissions are one of the most
common real breach causes at scale — the 2017 Equifax breach and
countless leaked cloud storage buckets over the years trace back to
exactly this category of mistake: something readable/writable that
shouldn't have been.

**Check yourself:** what chmod number gives the owner full access and
everyone else nothing?

---

## Day 3 — Text editors: nano and vim

**Objective:** edit files directly on the server — you'll need this
for every day from here on, especially scripting.

**Do this (nano — the easy one):**
```bash
nano notes.txt
```
Type a line of text. At the bottom, `^O` means `Ctrl+O` (write out /
save), `^X` means `Ctrl+X` (exit). Save and exit, then:
```bash
cat notes.txt
```
**What's happening / why:** `nano` shows its shortcuts on screen at all
times — no memorization needed. Good enough for 90% of quick edits.

**Do this (vim — the one everywhere, worth learning properly):**
```bash
vim notes2.txt
```
Vim has **modes** — this trips up everyone at first:
- You start in **Normal mode** (keys are commands, not text)
- Press `i` to enter **Insert mode** (now you can type text normally)
- Press `Esc` to go back to Normal mode
- Type `:wq` then `Enter` to **w**rite (save) and **q**uit
- Type `:q!` then `Enter` to quit **without** saving (escape hatch if
  you get stuck — memorize this one first)

**Try this exact sequence:** `vim notes2.txt`, press `i`, type
`hello from vim`, press `Esc`, type `:wq`, press `Enter`.
```bash
cat notes2.txt
```
**You should see:** `hello from vim`

**A few more vim moves worth knowing:**
- `dd` (Normal mode) — delete the current line
- `u` — undo
- `/searchterm` then `Enter` — search in the file, `n` for next match
- `:%s/old/new/g` — replace every "old" with "new" in the whole file

**What's happening / why:** vim is installed on nearly every Linux
server by default, unlike fancier editors — knowing at least `i`,
`Esc`, `:wq`, and `:q!` means you're never stuck editing a config file
on a random remote machine.

**🌍 In the real world:** the "vi vs emacs" editor rivalry dates back to
the 1970s and is still a running joke in the field. The practical
reason vim endures: it's preinstalled on nearly every Linux server on
Earth, so knowing it means you're never stuck when GUI editors and
mouse support simply aren't an option — which is most of the time on a
remote server.

**Check yourself:** you open a file in vim, make changes you didn't
mean to make, and want to abandon them entirely. What do you type?

**Self-check:** `bash ~/training/check_day3.sh` — confirms `notes.txt`
and `notes2.txt` exist with the expected content.

---

## Day 4 — Environment variables and `$PATH` **(host)**

**Objective:** understand how the shell finds commands and stores
settings — this explains a huge chunk of "why doesn't this work" bugs
you'll hit for the rest of your Linux life.

**Do this:**
```bash
echo $HOME
echo $PATH
export MY_NAME="trainee"
echo $MY_NAME
which ls
```
**You should see:** your home directory, a colon-separated list of
directories, `trainee`, and the full path to the `ls` binary (something
like `/usr/bin/ls`).

**What's happening / why:** environment variables are named values
available to your shell and anything it runs. `$PATH` is a special
one: a list of directories the shell searches, in order, whenever you
type a bare command name — that's literally how `which ls` finds it.
`export` makes a variable visible to child processes too, not just your
current shell.

**Try this (safe to break — it only affects your current session):**
```bash
PATH=""
ls
```
**You should see:** `bash: ls: command not found` — even though the
`ls` program is still sitting right there on disk. Close and reopen
your terminal (or just log back in) to get a normal `$PATH` back.

**What's happening / why:** this proves `$PATH` — not the file's
existence — is what makes a command findable by name. If `$PATH`
doesn't include the folder a program lives in, typing its name fails,
even though running it by full path (`/usr/bin/ls`) would still work
fine.

**Now make a variable persist across every future login:**
```bash
echo 'export TRAINING_ENV="sandbox"' >> ~/.bashrc
source ~/.bashrc
echo $TRAINING_ENV
```
**You should see:** `sandbox`

**What's happening / why:** `.bashrc` runs every time you open a new
shell — anything `export`ed there becomes permanent, not just for this
session. `source` re-runs it immediately instead of waiting for your
next login (this is exactly the trick used to activate the `docker`
group and the login banner earlier in this project).

**🌍 In the real world:** "command not found" despite software clearly
being installed is one of the most common early points of confusion —
the overwhelming majority of the time it's a `$PATH` problem, not a
broken install.

**Check yourself:** if you installed a program but typing its name
gives `command not found`, what two things would you check first?

**Self-check:** `bash ~/training/check_day4.sh`

---

## Week 1 Review — before moving on

Answer these from memory, no looking back. Bring your answers to a
Claude session to talk through anything shaky — this is the point
where slow-and-steady pays off, not a formality to skip.

1. What do the 10 characters in `ls -l`'s permission string represent?
2. Why did `root` ignore the `chmod 000` you set on `file.txt`?
3. In vim, what's the fastest way to abandon changes and quit without
   saving?
4. What's the difference between Normal mode and Insert mode in vim?
5. What is `$PATH`, and what breaks if a directory isn't in it?

# Week 2 — Multi-User Linux

## Day 5 — Users and groups **(host)**

**Objective:** understand multi-user Linux for real.

**Do this:**
```bash
cat /etc/passwd | tail -5
sudo useradd -m -s /bin/bash trainee
sudo groupadd learners
sudo usermod -aG learners trainee
id trainee
```
**You should see:** `uid=1001(trainee) gid=1001(trainee)
groups=1001(trainee),1002(learners)`

**What's happening / why:** every account lives in `/etc/passwd`. `-m`
creates a home directory, `-aG` **appends** to a group without
wiping existing memberships (`-G` without `-a` would wipe them — a
classic mistake). This is the exact pattern used to add `ubuntu` to the
`docker` group earlier in this project.

**🌍 In the real world:** mismanaged group/permission grants are a
recurring theme in real intrusions and internal data leaks — someone
gets added to a group "just for now" that never gets revoked, or a
script overwrites a group list instead of appending to it (exactly
what `-aG` protects against) and quietly strips someone's real access.

**Check yourself:** why `-aG` and not just `-G`?

**Self-check:** `bash ~/training/check_day5.sh`

---

## Day 6 — Processes

**Objective:** see what's running and control it.

**Do this:**
```bash
ps aux | head -10
sleep 300 &
jobs
kill %1
jobs
```
**You should see:** a process table, a backgrounded job, then
`Terminated` after `kill`.

**What's happening / why:** `&` backgrounds a command. `jobs` lists
background jobs from *this shell*; `ps aux` lists *everything* on the
system. `%1` refers to job number 1 from `jobs` — `kill` also accepts a
raw PID. `kill` asks nicely by default; `kill -9` forces it, for when a
process won't respond to the polite request.

**🌍 In the real world:** Knight Capital's infamous 2012 trading
incident — a $440M loss in 45 minutes — was partly caused by an old
process that should never have still been running getting triggered
against live production. "What's actually running right now, and
should it be" is a genuinely load-bearing question in production
systems, not just a sandbox exercise.

**Check yourself:** when might `kill <pid>` (no `-9`) fail to stop
something?

---

## Day 7 — Installing software **(host)**

**Objective:** get fluent with the package manager.

**Do this:**
```bash
sudo apt update
sudo apt install -y cowsay
cowsay "hello sandbox"
which cowsay
dpkg -L cowsay | head -5
```
**You should see:** cowsay's ASCII output, its install path, and a
list of every file the package owns.

**What's happening / why:** `apt update` refreshes the *list* of
available versions — it installs nothing by itself. `apt install` does
the actual work. `dpkg -L` shows that "installing a package" really
means "copy files to specific places and record it."

**🌍 In the real world:** software supply-chain attacks — malicious
packages slipped into trusted repositories, like the 2024 `xz-utils`
backdoor that nearly compromised SSH across huge swaths of the
internet — exploit exactly the trust you place in `apt install`. Every
install is you trusting that the maintainer's code does what it says.

**Check yourself:** what's the difference between `apt remove cowsay`
and `apt purge cowsay`?

**Self-check:** `bash ~/training/check_day7.sh`

---

## Week 2 Review — before moving on

1. What's the difference between `usermod -G` and `usermod -aG`, and
   why does it matter?
2. What does `&` do to a command, and how is that different from a
   process just running normally in your terminal?
3. What's the difference between `kill <pid>` and `kill -9 <pid>`?
4. What does `apt update` actually do — and what does it *not* do?
5. What's the difference between `apt remove` and `apt purge`?

## 🔗 External checkpoint: OverTheWire Bandit, levels 0-8

**Go here:** [overthewire.org/wargames/bandit](https://overthewire.org/wargames/bandit/)
(free, no signup required)

**What it is:** a famous, gamified "wargame" — each level is a real SSH
login where the password to the *next* level is hidden somewhere you
have to find using exactly what you've learned so far: navigation,
`ls -la`, permissions, `find`, reading files. Level 0's connection
details and starting password are right there on the page.

**Do this:** work through **levels 0 to 8** — that's the range that
matches Weeks 1-2 of this course. Don't rush past a level you had to
guess your way through; if you didn't understand *why* a command
worked, that's worth more than the password itself.

**Come back and tell me:** which level gave you the most trouble, and
why. If you get properly stuck on one, that's a great thing to bring
to a Claude session — talking through *why* a level isn't working
teaches more than the answer would.

# Week 3 — Text Wrangling & Automation

## Day 8 — Pipes, grep, and find

**Objective:** combine small tools instead of memorizing giant ones.

**Do this:**
```bash
ps aux > processes.txt
grep bash processes.txt
wc -l processes.txt
find / -maxdepth 2 -name "*.conf" 2>/dev/null
```
**You should see:** filtered lines containing "bash", a line count,
and a list of `.conf` files found by searching the filesystem.

**What's happening / why:** `>` redirects output to a file; `|` (used
on Day 1 implicitly, now explicitly) pipes one command's output into
another's input. `grep pattern file` filters lines matching a pattern
— it also works as `cmd | grep pattern` on live output. `find` searches
the filesystem by name, type, size, age, and more — `2>/dev/null`
throws away "permission denied" noise from folders you can't read.

**🌍 In the real world:** "small tools, piped together" is literally
named the Unix Philosophy (formalized in the late 1970s) and it's still
exactly how most real log analysis and incident response happens
today, decades later — nobody writes one giant program to investigate
a production issue, they chain `grep`, `awk`, `sort`, `uniq` together
live.

**Check yourself:** write one line, using a pipe, that tells you how
many processes are currently running — without creating a file.

---

## Day 9 — Regex basics with grep and sed

**Objective:** search and replace by *pattern*, not just exact text.

**Do this:**
```bash
printf "cat\nbat\ncar\ndog\n" > animals.txt
grep "^c" animals.txt
grep "at$" animals.txt
grep -E "c(a|o)t" animals.txt
sed 's/cat/CAT/' animals.txt
```
**You should see:** lines starting with `c` (cat, car), lines ending in
"at" (cat, bat), lines matching "cat" or "cot" pattern (cat), and the
file printed with "cat" replaced by "CAT" (the file itself isn't
changed unless you add `-i`).

**What's happening / why:** `^` anchors to the start of a line, `$` to
the end. `-E` enables "extended" regex so `|` (alternation) and `()`
(grouping) work without extra backslashes. `sed 's/find/replace/'`
substitutes the first match per line; add a trailing `g` to replace
every match, and `-i` to edit the file in place instead of just
printing the result.

**🌍 In the real world:** Cloudflare had a 27-minute *global* outage in
2019 caused by a single catastrophically slow regular expression
deployed to their edge network (a "ReDoS" — regex denial of service).
Regex is genuinely powerful and genuinely dangerous when careless —
worth respecting, not just memorizing syntax for.

**Check yourself:** what would `sed -i 's/cat/CAT/g' animals.txt` do
differently from the command above?

---

## Day 10 — Shell scripting basics

**Objective:** write it once, run it forever.

**Do this:** using `vim` or `nano` from Day 3, create
`~/training/myscript.sh` **(host, so it persists for the self-check)**:
```bash
#!/bin/bash
echo "Starting setup..."
mkdir -p demo
touch demo/one.txt demo/two.txt demo/three.txt
echo "Created $(ls demo | wc -l) files in ./demo"
```
```bash
chmod +x ~/training/myscript.sh
~/training/myscript.sh
```
**You should see:**
```
Starting setup...
Created 3 files in ./demo
```
**What's happening / why:** `#!/bin/bash` (the "shebang") tells the OS
which interpreter runs the file. `chmod +x` grants execute permission
(Day 2). `$(...)` substitutes a command's output inline.

**🌍 In the real world:** small internal bash scripts exactly like this
one quietly run a huge amount of real infrastructure — deployment
steps, cleanup jobs, "glue" between systems — at literally every tech
company. It's rarely glamorous, but it's genuinely everywhere.

**Check yourself:** what error would you get running the script
*without* `chmod +x` first?

**Self-check:** `bash ~/training/check_day10.sh`

---

## Day 11 — Bash error handling: `set -e` and `trap` **(host)**

**Objective:** make scripts fail loudly and predictably instead of
quietly limping on after something breaks.

**Do this:** create `~/training/risky.sh`:
```bash
#!/bin/bash
mkdir /this/path/does/not/exist
echo "This line still runs even though the mkdir above failed!"
```
```bash
chmod +x ~/training/risky.sh
~/training/risky.sh
```
**You should see:** the `mkdir` error printed, **and then** the echo
line prints anyway — proving bash just plows ahead after a failure by
default.

**Now create `~/training/safe_script.sh`:**
```bash
#!/bin/bash
set -e
mkdir /this/path/does/not/exist
echo "This line should never print"
```
```bash
chmod +x ~/training/safe_script.sh
~/training/safe_script.sh
```
**You should see:** just the error — the script stops immediately, the
echo line never runs.

**What's happening / why:** `set -e` tells bash to stop the entire
script the instant any command fails (returns a non-zero exit code),
instead of logging the error and continuing. This turns silent partial
failures into loud, immediate, obvious ones.

**One more piece — `trap`:**
```bash
#!/bin/bash
set -e
trap 'echo "Something failed on line $LINENO"' ERR
mkdir /this/path/does/not/exist
```
**What's happening / why:** `trap` runs a command automatically when a
condition occurs — here, `ERR` fires whenever a command fails. This is
a small taste of the same idea behind real alerting systems: don't just
fail, *say something* when you fail.

**🌍 In the real world:** unchecked failures inside deployment scripts
have caused real production outages — one step silently fails, the
script barrels on as if nothing happened, and the system ends up in a
half-updated, broken state. `set -e` (and its stricter cousin
`set -euo pipefail`) is close to a default best practice for any bash
script that matters.

**Check yourself:** what's the practical difference in behavior
between `risky.sh` and `safe_script.sh`, and why would that matter for
a real deployment script?

**Self-check:** `bash ~/training/check_day11.sh`

---

## Day 12 — Scheduling with cron **(host)**

**Objective:** make something run automatically, without you.

**Do this:**
```bash
crontab -l
echo '* * * * * echo "cron ran at $(date)" >> ~/training/cron_log.txt' | crontab -
```
Wait about a minute, then:
```bash
cat ~/training/cron_log.txt
```
**You should see:** an empty crontab initially (`no crontab for
ubuntu`), then, after waiting, one or more lines showing the current
time — proof it ran on its own.

**What's happening / why:** `* * * * *` means "every minute" — the five
fields are minute, hour, day-of-month, month, day-of-week; `*` means
"any." `crontab -l` lists your current schedule; piping into
`crontab -` replaces it. This is how you'd automate backups, cleanup
scripts, or health checks on a real server.

**Important — clean up after this exercise**, or it'll spam that file
forever:
```bash
crontab -r
```
**🌍 In the real world:** an old, forgotten cron-style job is a
recurring root cause behind real production incidents — something
scheduled years ago, nobody remembers why, that eventually fires
against a system that's since changed underneath it. Knowing exactly
what's scheduled (`crontab -l`) and cleaning up after yourself, like
you're about to, is a genuine habit worth keeping.

**Check yourself:** what would `0 3 * * *` mean instead of `* * * * *`?

**Self-check:** `bash ~/training/check_day12.sh` (run it *before*
`crontab -r`, while the job is still active, to see it confirmed)

---

## Week 3 Review — before moving on

1. What's the difference between `>` and `|`?
2. Write, from memory, a `grep` pattern that matches lines starting
   with "err" (case doesn't matter for this — just the anchor).
3. What does the `g` flag do at the end of a `sed 's/.../.../ g'`
   command that's missing without it?
4. What does the shebang line (`#!/bin/bash`) actually do?
5. What does `set -e` change about how a script behaves after a
   command fails?
6. In a cron schedule `* * * * *`, what do the five fields mean, in
   order?

## 🔗 External checkpoint: OverTheWire Bandit, levels 9-18

**Go here:** [overthewire.org/wargames/bandit](https://overthewire.org/wargames/bandit/)
(continue from wherever you left off — your progress is just "which
level's password do I currently have," there's no account to lose)

**Do this:** levels **9 to 18** lean much more heavily on `grep`,
`find` with more advanced flags, and basic scripting logic — exactly
Week 3's material. This range is noticeably harder than 0-8; that's
expected, and a good sign you're past the easy part.

**Come back and tell me:** if any level took you more than 15-20
minutes of genuine effort, it's worth reviewing here rather than just
moving on once you've solved it.

This is a 34-level wargame in total, and the plan across this course is
to eventually finish all of it — the next chunk (19-25, networking-
flavored) comes after Week 5, and the final push to level 34 is a
dedicated goal in Week 9, once the whole foundation is in place.

# Week 4 — Version Control & Services

## Day 13 — Git basics **(host)**

**Objective:** track changes to files over time — the exact tool this
project's own docs and scripts are managed with.

**Do this:**
```bash
mkdir -p ~/training/git-practice && cd ~/training/git-practice
git init
git config --global user.email "you@example.com"
git config --global user.name "Trainee"
echo "hello git" > notes.txt
git add notes.txt
git commit -m "first commit"
git log --oneline
```
**You should see:** an "initialized empty Git repository" message,
then a log with one line like `a1b2c3d first commit`.

**What's happening / why:** `git init` creates a new repository (a
hidden `.git` folder tracking history). `git add` **stages** a file —
marks it to be included in the *next* commit. `git commit` actually
saves a snapshot with a message. `git log` shows the history of
snapshots. This exact workflow — init, add, commit — is how the
`linux-sandbox` project's own docs and scripts are tracked, right on
your local machine.

**Try it — see history in action:**
```bash
echo "a second line" >> notes.txt
git status
git diff
git add notes.txt
git commit -m "add a second line"
git log --oneline
```
**You should see:** `git status` flags the file as modified, `git diff`
shows exactly what changed (a `+` line), and after committing, `git
log` now shows two commits.

**🌍 In the real world:** version control is arguably the single most
universally used tool in professional software work — from a two-person
side project to a company with thousands of engineers, nearly
everything gets tracked this way. Git specifically was created in 2005
by Linus Torvalds — the same person who created Linux itself.

**Check yourself:** what's the difference between `git add` and `git
commit`? Why are they two separate steps instead of one?

**Self-check:** `bash ~/training/check_day13.sh`

---

## Day 14 — systemd and services **(host)**

**Objective:** understand how background services are managed for
real — what's keeping `sshd` and `docker` alive.

**Do this:**
```bash
systemctl status docker
sudo journalctl -u docker -n 20
systemctl is-enabled docker
systemctl is-active docker
```
**You should see:** `Active: active (running)`, recent log lines from
just that service, and `enabled` / `active`.

**What's happening / why:** systemd starts, stops, and supervises
services. "Enabled" (starts on boot) and "active" (running right now)
are independent facts — confusing them causes real "but it worked
yesterday!" bugs. `journalctl -u <service>` filters logs to just one
service.

**🌍 In the real world:** systemd became the default init system across
nearly every major Linux distribution by the mid-2010s (not without
controversy) specifically because "is my service actually running, and
will it restart itself if it dies" needed a real, reliable answer —
silent service death used to be a genuinely common, hard-to-diagnose
cause of downtime.

**Check yourself:** if you ran `sudo systemctl disable docker` right
now, would Docker stop immediately?

**Self-check:** `bash ~/training/check_day14.sh`

---

## Day 15 — Write your own systemd service **(host)**

**Objective:** go from *using* services to *creating* one.

**Do this:** create `/etc/systemd/system/heartbeat.service` (needs
`sudo` + an editor, e.g. `sudo vim ...`):
```ini
[Unit]
Description=Heartbeat training service

[Service]
ExecStart=/bin/bash -c 'while true; do echo "beat $(date)" >> /home/ubuntu/training/heartbeat.log; sleep 5; done'
Restart=always

[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now heartbeat
sleep 12
sudo systemctl status heartbeat
cat ~/training/heartbeat.log
```
**You should see:** `Active: active (running)` and a few "beat ..."
lines appearing every 5 seconds.

**What's happening / why:** a unit file describes a service: what to
run (`ExecStart`), whether to restart it if it dies (`Restart=always`),
and when to start it automatically (`WantedBy=multi-user.target` =
normal boot). `daemon-reload` tells systemd to notice the new file;
`enable --now` both enables it for next boot *and* starts it now.

**Clean up when done exploring:**
```bash
sudo systemctl disable --now heartbeat
sudo rm /etc/systemd/system/heartbeat.service
sudo systemctl daemon-reload
```
**🌍 In the real world:** `Restart=always` is a small taste of
"self-healing" infrastructure — the same underlying idea (if it dies,
bring it back automatically, without a human) scales all the way up to
what Kubernetes does for entire fleets of containers in production.

**Check yourself:** what does `Restart=always` protect against that a
plain script run by hand doesn't?

**Self-check:** `bash ~/training/check_day15.sh` (run while the service
is still active, before cleanup)

---

## Day 16 — Backups: `tar` and `rsync` **(host)**

**Objective:** know how to actually protect and recover data — not
just create it.

**Do this:**
```bash
mkdir -p ~/important-data
echo "precious file" > ~/important-data/file1.txt
tar -czvf ~/training/backup-$(date +%Y%m%d).tar.gz -C ~ important-data
ls -lh ~/training/backup-*.tar.gz
```
**You should see:** `tar`'s verbose file listing while it archives,
then your `.tar.gz` file listed with its size.

**What's happening / why:** `tar` bundles files/directories into one
archive. `-c` create, `-z` gzip-compress, `-v` verbose (list files as
it works), `-f` the output filename. `-C ~` tells tar to change into
your home directory *first*, so the archive stores a clean relative
`important-data/` path instead of an ugly absolute one.

**Now prove the backup actually works — restore it:**
```bash
rm -rf ~/important-data
tar -xzvf ~/training/backup-*.tar.gz -C ~
cat ~/important-data/file1.txt
```
**You should see:** `precious file` printed — proof the backup was
real and restorable, not just something that ran without erroring.

**One more tool — `rsync`, for syncing instead of archiving:**
```bash
mkdir -p ~/important-data-copy
rsync -av ~/important-data/ ~/important-data-copy/
ls ~/important-data-copy/
```
**What's happening / why:** `rsync` copies efficiently, transferring
only what's changed on repeat runs — this is the tool real backup
systems and deployment pipelines use under the hood, not a
copy-paste toy. `-a` = archive mode (preserves permissions and
timestamps), `-v` = verbose.

**🌍 In the real world:** "we had backups, but never actually tested
restoring them" is a genuinely common and painful lesson learned the
hard way — a backup you haven't tested restoring isn't a real backup.
You just did both halves, in the right order.

**Check yourself:** why did this exercise have you delete
`important-data` and restore it from the archive, instead of just
trusting that the `tar` command exited without an error?

**Self-check:** `bash ~/training/check_day16.sh`

---

## Week 4 Review — before moving on

1. What's the difference between `git add` and `git commit`?
2. What's the difference between a service being "enabled" and being
   "active"?
3. In a systemd unit file, what does `Restart=always` actually protect
   against?
4. Why does a backup you've never tested restoring not really count as
   a backup?
5. What's the practical difference between `tar` and `rsync`?

# Week 5 — Networking

## Day 17 — Networking basics **(host)**

**Objective:** understand what's happening when you SSH in or a
container reaches the internet.

**Do this:**
```bash
ip addr
sudo ss -tulpn
curl -I https://example.com
dig example.com
```
**You should see:** this machine's interfaces and IPs, a table of
listening ports (you'll recognize `:22` from `sshd`), an HTTP response
header block, and a DNS answer resolving the domain to an IP.

**What's happening / why:** the public IP you SSH to isn't actually
configured *on* this box — Oracle's network translates it to the
private IP you see in `ip addr`. `ss -tulpn` is the exact command used
early in this project to work out what the pre-existing `vpn-server`
box was running, just from its open ports. `dig` shows the name→IP
lookup that happens *before* any connection.

**🌍 In the real world:** the 2021 global outage that took down
Facebook, Instagram, and WhatsApp simultaneously was ultimately a
networking misconfiguration (BGP routing) — the same category of "what
can actually reach what, and why" question you're practicing here,
just playing out at planetary scale instead of one sandbox box.

**Check yourself:** what's the difference between "is this port open"
and "is this domain reachable at all"?

---

## Day 18 — Firewall **(host)**

**Objective:** control what can reach this box at the network level.

> Go slowly. Never `enable` a firewall without first explicitly
> allowing SSH — locking yourself out of a cloud box is a common and
> painful mistake.

**Do this:**
```bash
sudo ufw status verbose
```
**You should see (likely):** `Status: inactive`.

**What's happening / why:** `ufw` is Ubuntu's friendly frontend over
the kernel's real firewall. Checking status *before* changing anything
is the "verify, don't assume" habit this whole project runs on.

**🌍 In the real world:** "locked myself out of my own cloud server with
the firewall" is one of the single most common mistakes junior
engineers make — genuinely a rite of passage. You now know the exact
rule (allow SSH *before* enabling) that prevents it.

**Self-check:** `bash ~/training/check_day18.sh` (read-only, makes no
changes)

**Talk-it-through-live exercise (come back to a session for this):**
the safe sequence to actually turn it on is *allow SSH first*, confirm
it's in the ruleset, **then** enable, then verify you can still connect
from a *second* terminal before closing your first one.

---

## Week 5 Review — before moving on

1. Why isn't the public IP you SSH to actually configured on the box
   itself?
2. What does `ss -tulpn` tell you that `ps aux` doesn't, and vice
   versa?
3. What's the golden rule for the *order* of operations when enabling
   a firewall on a remote box, and why?
4. What does `dig` show you that `curl` doesn't?

## 🔗 External checkpoint: OverTheWire Bandit, levels 19-25

**Go here:** [overthewire.org/wargames/bandit](https://overthewire.org/wargames/bandit/)
(continue from your saved progress)

**Do this:** levels **19 to 25** lean heavily on networking — ports,
`nc` (netcap), talking to services directly over a raw connection —
exactly what Week 5 just covered. Some of these will take real
persistence; that's normal at this depth.

**Come back and tell me:** how it felt applying `ss`/networking
concepts against a genuinely unfamiliar box, versus this sandbox where
you already know what's running.

# Week 6 — Docker Deep Dive

## Day 19 — Building your own images

**Objective:** understand what's happening underneath `docker run`.

**Do this:**
```bash
docker images
docker pull alpine
docker images
```
Then create a `Dockerfile`:
```dockerfile
FROM ubuntu
RUN apt update && apt install -y cowsay
CMD ["cowsay", "built by me"]
```
```bash
docker build -t mycowsay .
docker run --rm mycowsay
```
**You should see:** `alpine` appear after pulling (a few MB — tiny
compared to `ubuntu`), a build log, then cowsay output baked into the
image with no install step needed at run time.

**What's happening / why:** a `Dockerfile` is a recipe — `FROM` a base,
`RUN` setup commands, `CMD` what runs by default. `-t` tags the built
image with a name, same as `ubuntu` or `alpine`.

**🌍 In the real world:** Docker's rise after 2013 fundamentally
reshaped how software gets shipped, specifically because "works on my
machine, breaks in production" had been such a chronic, expensive
problem for decades — a `Dockerfile` is a machine-checkable answer to
"exactly what does this environment need."

**Check yourself:** why is `docker run --rm mycowsay` faster on repeat
runs than `docker run --rm ubuntu` + installing cowsay each time?

---

## Day 20 — Volumes and networks

**Objective:** make data survive a container being deleted, and let
containers talk to each other.

**Do this:**
```bash
docker volume create mydata
docker run --rm -v mydata:/data ubuntu bash -c "echo hello > /data/note.txt"
docker run --rm -v mydata:/data ubuntu cat /data/note.txt
```
**You should see:** `hello`, printed by the *second*, completely
separate container — proving the data lived in the volume, not the
container.

**Do this too:**
```bash
docker network create mynet
docker run -d --rm --name web --network mynet nginx
docker run --rm --network mynet alpine wget -qO- http://web
```
**You should see:** the nginx default welcome page's HTML, fetched by
one container from another **by container name** — no IP needed.

**What's happening / why:** containers are throwaway by design; volumes
are the deliberate exception — data placed in a volume outlives any
container. A custom network lets containers resolve each other by
name, which is exactly how multi-container apps (next lesson) talk to
each other.

**🌍 In the real world:** treating a container like a permanent server —
forgetting it's disposable and storing important data directly inside
it instead of a volume — is one of the most common real mistakes
beginners make with Docker, usually discovered the hard way when the
container gets recreated and the data is just gone.

**Check yourself:** what would have happened in the volume example if
you'd used two *different* volume names instead of `mydata` both
times?

---

## Day 21 — Docker Compose: multi-container apps **(host)**

**Objective:** run a real multi-service app with one command.

**Do this:** create `~/training/compose-demo/docker-compose.yml`:
```yaml
services:
  web:
    image: nginx
    ports:
      - "8080:80"
  redis:
    image: redis
```
```bash
cd ~/training/compose-demo
docker compose up -d
docker compose ps
curl -I http://localhost:8080
docker compose logs redis | tail -5
```
**You should see:** both services listed as running, an HTTP 200 from
nginx, and redis's startup logs.

**What's happening / why:** `docker-compose.yml` describes a whole
group of containers — this is how real applications are usually
defined (a web server + a database + a cache, etc.), instead of typing
several long `docker run` commands by hand. `docker compose up -d`
starts everything, networked together automatically (services can
reach each other by name, e.g. `redis`, same idea as Day 20).

**Clean up when done:**
```bash
docker compose down
```
**🌍 In the real world:** `docker-compose.yml` (and its more elaborate
descendant, Kubernetes YAML) is genuinely how a huge share of real
production infrastructure is described today — this is not a toy
format, it's the same shape of file running actual companies' backends.

**Check yourself:** if `web`'s code needed to talk to `redis`, what
hostname would it use — an IP address, or just `redis`?

**Self-check:** `bash ~/training/check_day21.sh` (run while `docker
compose up -d` is still active)

---

## Week 6 Review — before moving on

1. Why did `docker run --rm mycowsay` not need to reinstall cowsay
   every time, once it was built into the image?
2. What problem do Docker volumes solve that containers alone don't?
3. In the `docker network` exercise, how did one container reach
   another by name instead of by IP — what made that possible?
4. What's the actual advantage of a `docker-compose.yml` file over
   several separate `docker run` commands?

## 🔗 External checkpoint: KodeKloud free Docker labs

**Go here:** [kodekloud.com](https://kodekloud.com/) — look for their
free Docker course/labs (their catalog changes over time, so search
"Docker" once you're on the site).

**What it is:** guided, browser-based labs — no need to set anything
up locally — that go deeper into Docker than this course did:
multi-stage builds, registries, and more realistic multi-container
setups than the nginx+redis demo from Day 21.

**Do this:** work through whatever free Docker labs are currently
available. This is intentionally open-ended — the goal is repetition
and seeing Docker used in a slightly different style than this course's
examples, not a specific checklist. Week 9 comes back to this platform
for a full pass through everything free it offers — this first visit
is just to get oriented.

**Come back and tell me:** one thing they did differently from how this
course explained it — comparing explanations is a great way to make an
idea actually stick.

# Week 7 — Security

## Day 22 — SSH and basic hardening **(host)**

**Objective:** understand the security model you've relied on this
whole project.

> Go slowly — this is the day most likely to lock you out if rushed.

**Do this:**
```bash
cat ~/.ssh/authorized_keys
sudo grep -E "PasswordAuthentication|PermitRootLogin" /etc/ssh/sshd_config
```
**You should see:** two key lines in `authorized_keys` (from earlier in
this project), and config lines like `PasswordAuthentication no`.

**What's happening / why:** `authorized_keys` is the literal, complete
list of who can log in as `ubuntu` via key auth. `PasswordAuthentication
no` means nobody can log in with just a password — only a matching
private key, which can't be brute-forced the way passwords can.

**🌍 In the real world:** key-only SSH auth became close to a universal
default on serious internet-facing servers largely because
password-based brute-force campaigns are constant and automated —
bots try common username/password combinations against essentially
every public IP, all day, every day. Key-only makes that entire class
of attack irrelevant.

**Check yourself:** what extra risk would `PasswordAuthentication yes`
open up, given this box is reachable from the whole internet?

---

## Day 23 — fail2ban: automated intrusion protection **(host)**

**Objective:** actively defend against brute-force login attempts.

**Do this:**
```bash
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
```
**You should see:** fail2ban active, and an `sshd` jail showing current
ban count (likely 0, unless this box has been attacked recently — it's
worth checking).

**What's happening / why:** fail2ban watches log files (like SSH's) for
repeated failed login attempts and temporarily firewalls the offending
IP. It's a standard, low-effort layer of defense on any
internet-facing box — exactly what this sandbox is.

**🌍 In the real world:** internet-wide scanning bots probe essentially
every public IPv4 address around the clock, sandbox or not — this
isn't paranoia, it's baseline hygiene for anything internet-facing.
Check your own `sshd` jail status above; it's a genuinely eye-opening
first look at how much automated noise a plain public IP attracts.

**Check yourself:** why does fail2ban matter *in addition to* key-only
SSH auth from Day 22, not instead of it?

**Self-check:** `bash ~/training/check_day23.sh`

---

## Day 24 — Reading the trail: logs and auditing **(host)**

**Objective:** answer "who did what, and when" using real logs.

**Do this:**
```bash
last -x | head -10
sudo journalctl -u ssh -n 20 --no-pager
sudo grep "Failed password" /var/log/auth.log | tail -5
```
**You should see:** recent login history, SSH service logs, and any
failed login attempts recorded (there may be none, or several — the
internet scans every SSH-facing IP constantly, this is normal).

**What's happening / why:** this is the exact command style used at the
very start of this project to work out when the two pre-existing
Oracle instances were created and last used. Every serious "what
happened here" investigation starts with logs, not guessing.

**🌍 In the real world:** major breaches — the 2013 Target breach among
them — are very often *detected* well after the fact, purely through
patient log analysis, not caught in real time. Calmly reading logs
after something's already gone wrong is one of the most valuable and
most underrated skills in this entire field.

**Check yourself:** if you saw 50 failed password attempts from one IP
in the last hour, what would you check or do next, based on Days 18 and
23?

---

## Week 7 Review — before moving on

1. Why does `PasswordAuthentication no` matter even though you always
   log in with a key anyway?
2. What does fail2ban actually do, mechanically, when it detects
   repeated failed logins?
3. Why is fail2ban a *complement* to key-only SSH, not a replacement
   for it?
4. Name two log sources you'd check first if you suspected someone was
   trying to break into this box.

## 🔗 External checkpoint: TryHackMe "Linux Fundamentals"

**Go here:** [tryhackme.com](https://tryhackme.com/) — search for the
"Linux Fundamentals" room path (has a free tier).

**What it is:** guided, more security-flavored Linux practice than
Bandit — a natural next step now that Week 7's hardening/fail2ban/log
material gives you the context to appreciate *why* the security-focused
exercises matter, not just how to run the commands. This first visit is
just to get started; Week 9 comes back to finish the whole path
properly.

**Come back and tell me:** how the security framing felt different from
the purely "how do I use this tool" framing earlier in this course —
that shift in mindset is the actual point of Week 7. Bandit's next
stretch — level 26 onward, into real privilege-escalation territory —
is waiting for you in Week 9.

# Week 8 — Guru Capstones

## Day 25 — Mini investigation

**Objective:** debug something yourself, no script gives you the
answer.

Pick one and work it out using everything from Weeks 1-7:
- **What's listening right now, and why?** — combine `ss -tulpn` with
  `ps aux` to match each port to its actual program.
- **How much disk space, and on what?** — `df -h`, `du -sh *`.
- **Who's logged in, and when?** — `last -x`.

Write down what you found and why — that's the actual exercise.

---

## Day 26 — Capstone: deploy a real service **(host)**

**Objective:** combine packages, systemd, and the firewall into one
real, working deployment.

**Do this:**
```bash
sudo apt install -y nginx
echo "<h1>Deployed by $(whoami) on $(date)</h1>" | sudo tee /var/www/html/index.html
sudo systemctl enable --now nginx
sudo ufw allow 80/tcp
curl -I http://localhost
```
**You should see:** `HTTP/1.1 200 OK` from your own custom page.

**What's happening / why:** this is the full real-world pattern: install
software (Week 2), it registers itself as a systemd service (Week 4),
you open the right firewall port (Week 5) — three separate skills from
this course, combined into one actual working website.

**🌍 In the real world:** this exact stack — install, systemd, firewall
— is genuinely how a meaningful fraction of the small-to-medium web
still gets deployed today, no fancier than what you just did. There's
real satisfaction in knowing that a "simple" personal blog or small
business site is, underneath, doing roughly this.

**Check yourself:** if `curl -I http://localhost` works from *on* the
box but the page isn't reachable from your own laptop's browser using
the public IP, which of the three steps above would you suspect first?

**Self-check:** `bash ~/training/check_day26.sh`

---

## Day 27 — Capstone: WireGuard VPN **(host)**

**Objective:** the secondary interest from `CLAUDE.md` — self-hosting a
VPN. By now you have the networking, packages, systemd, and firewall
background to actually understand what you're setting up.

This is a proper mini-project — come back to a live session and we'll
scope and build it together rather than scripting it in advance.

**🌍 In the real world:** WireGuard (first released 2016) was merged
directly into the Linux kernel itself in 2020 — a rare honor — because
it was such a dramatic simplification over older VPN protocols like
OpenVPN and IPsec. The `vpn-server` box mentioned elsewhere in this
project actually runs OpenVPN; building WireGuard here will give you a
genuine point of comparison between the two.

---

## Day 28 — Capstone: tie it all together

**Objective:** one last project combining scripting, error handling,
cron, and systemd — build a tiny automated health-check system.

**Rough brief (work this out yourself, ask for help where you get
stuck):** write a script (with `set -e` from Day 11 in mind) that
checks whether `nginx` (Day 26) is responding, logs the result with a
timestamp, and — if it's down — attempts to restart it via `systemctl`.
Schedule it with cron (Day 12) to run every 5 minutes. This is a
simplified version of what real monitoring systems (Nagios, Prometheus
alerting, etc.) do under the hood.

**🌍 In the real world:** you've just built a tiny version of what tools
like Nagios (2002) and Prometheus (2012) do for a living at essentially
every serious tech company: automated "is it up, and if not, try to
fix it, and tell someone if you can't." Nearly everything from this
whole course — scripting, error handling, cron, systemd, networking —
feeds into this one capstone. That's not a coincidence; it's genuinely
how these pieces fit together in real infrastructure.

---

---

# Week 9 — External Mastery

Everything up to here was building the foundation. These four days have
no new material from this course — the whole point is that you no
longer need it. Each one sends you to fully finish something you only
sampled earlier, using nothing but skills you already have. This is
where "completed the course" turns into "proven, outside this one box,
that it actually stuck."

## Day 29 — Finish OverTheWire Bandit, levels 26 through 34

**Go here:** [overthewire.org/wargames/bandit](https://overthewire.org/wargames/bandit/)

**Do this:** finish the wargame. This final stretch is genuinely hard —
expect git repository archaeology, cron-based traps, private key
recovery, and light privilege escalation. Take it slowly, level by
level; some may take multiple sessions. That's expected, not a sign
you're behind.

**Come back and tell me:** which level was the hardest, and walk me
through how you eventually solved it — explaining a solved problem out
loud is one of the best ways to confirm you actually understood it
(not just stumbled into the answer).

**Self-check:** none — this one's genuinely unverifiable from here,
self-report with `course.sh done 29` once you've reached level 34.

---

## Day 30 — Finish the TryHackMe "Linux Fundamentals" path

**Go here:** [tryhackme.com](https://tryhackme.com/)

**Do this:** complete every room in the Linux Fundamentals path, not
just the first one you tried back in Week 7. Take notes on anything
that used a tool or concept this course didn't cover — that's your own
personal "next things to look up" list.

**Come back and tell me:** what (if anything) came up that wasn't in
this course at all — that's genuinely useful signal for what to add
next.

**Self-check:** none — mark it yourself with `course.sh done 30` once
the path is complete.

---

## Day 31 — Finish the KodeKloud free Docker labs

**Go here:** [kodekloud.com](https://kodekloud.com/)

**Do this:** work through everything free their Docker catalog currently
offers, start to finish — not just a sample this time. Pay particular
attention to anything involving multi-stage builds, registries, or
orchestration concepts that go beyond Week 6's Compose material.

**Come back and tell me:** whether anything there changed how you'd
approach the `Dockerfile` you wrote back on Day 19 — a good sign the
extra practice actually taught you something new, not just repetition.

**Self-check:** none — mark it yourself with `course.sh done 31`.

---

## Day 32 — Where to go from here (open-ended, optional)

**Objective:** point yourself at what's next, now that the fundamentals
are genuinely solid.

If you want more of what Bandit gave you, OverTheWire has several other
free wargames worth knowing about: **Natas** (web application security),
**Leviathan** (beginner-friendly binary/exploitation basics), and
**Krypton** (cryptography puzzles) are the natural next steps — all at
the same site, same style, no signup.

This day has no fixed exercise — it's a prompt to come back to a Claude
session and talk through what genuinely interested you most across this
whole course (security? automation? Docker/orchestration? networking?)
so the *next* course can be scoped around that, the same way this one
was scoped around "zero to guru" at the start.

---

## After this

You've now covered real sysadmin fundamentals end to end — shell,
permissions, environment variables, users, processes, packages, text
wrangling, scripting with real error handling, git, backups, cron,
systemd, networking, firewalls, Docker (including Compose), and
security hardening — plus two real deployed capstones, and full
completions of three respected external platforms (OverTheWire Bandit,
TryHackMe Linux Fundamentals, KodeKloud Docker labs). That combination
— built-here fundamentals *and* proven against material this project
didn't write — is a genuinely solid, credible foundation. Natural next
directions from here: Ansible (automating server setup itself), a
proper CI/CD pipeline, Kubernetes, or one of the wargames from Day 32.
Ask when you get there.
