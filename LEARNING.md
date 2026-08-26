# Linux Learning Path — Zero to Guru

A 9-week, 29-day training course for the `linux-sandbox` box. No prior
Linux knowledge assumed beyond what you've already done in this
project (SSH in, run `docker run`).

**A steady progression, not a big jump at the end:** alongside each
day's core lesson, you'll also solve one level of
[OverTheWire Bandit](https://overthewire.org/wargames/bandit/) — a
free, no-signup SSH wargame where each level is a real login and the
password to the next level is hidden somewhere you have to find. By
the time you finish Week 8, you'll have solved **all 34 levels**, one
or two at a time, each one applying what that day just taught against
a box this course didn't build for you. Day 29 is a single final skills
test on a different platform, to prove it all transfers.

**How each day works:**
- **Do this** — the exact command(s) to type
- **You should see** — a realistic example of the output, so you can
  tell if it worked (your exact numbers/names will differ — the
  *shape* of the output is what matters)
- **What's happening / why** — the reasoning, not just the syntax
- **Decode it** — on days where the output has several non-obvious
  fields (`id`, `ps aux`, `systemctl status`, `ss -tulpn`, `last -x`,
  etc.), a field-by-field breakdown of what each part actually means —
  so you can read real output on your own, without needing this course
  open next to you
- **🌍 In the real world** — how this actually shows up in real
  incidents and real practice, not just theory
- **🎯 Apply it** — the Bandit level to solve today, applying what you
  just learned against an unfamiliar box
- **Check yourself** — a question to answer in your own words *before*
  moving on
- **Self-check** — where a script on the instance can verify your work
  against real system state

**Where to practice:** unless marked **(host)**, work inside a
disposable container: `docker run -it --rm ubuntu bash` (see
[USE_ME.md](USE_ME.md)). **(host)** days need the real machine —
users, systemd, cron, git history, and real networking don't exist in
a bare container. Bandit itself is always a separate SSH connection to
`bandit.labs.overthewire.org`, regardless of what the day's main
exercise uses.

**Pace:** there is no deadline here. With a Bandit level built into
every day, most days will genuinely take a real sitting — 30-60+
minutes is normal, sometimes more on the harder levels, and that's the
point, not a problem. ~3 days a week gets you through this in about
10 weeks; 1 day a week is just as valid and means several months. Any
day can be split across two sessions — do the core lesson, stop, come
back later for that day's Bandit level. Understanding beats speed
every time. Come back anytime and say "day N" — I'll walk through it
live, answer questions, and check your work.

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

**Decode it — `id`'s output will look like:**
```
uid=1001(ubuntu) gid=1001(ubuntu) groups=1001(ubuntu),4(adm),24(cdrom),27(sudo),30(dip),105(lxd),988(docker)
```
- **`uid=1001(ubuntu)`** — your numeric user ID is `1001`; the name
  `ubuntu` is just a label looked up from `/etc/passwd`. Everything
  under the hood is tracked by number, not name. `0` is always root;
  low numbers (roughly 1-999) are reserved for system/service accounts
  created automatically; real human accounts conventionally start at
  `1000`. So `1001` is a small clue that this was likely the *second*
  human account ever created on this box.
- **`gid=1001(ubuntu)`** — your primary group, confusingly also
  numbered and named the same as your user. That's Ubuntu's default
  "user private groups" behavior: every new user silently gets a
  same-named group as their primary one.
- **`groups=...`** — the *full* list: your primary group plus every
  extra group you belong to. Each one grants access to something
  specific — `sudo` is the important one (it's literally what allows
  you to run `sudo` at all — configured in `/etc/sudoers`); `docker`
  is the one added earlier in this project so you don't need `sudo`
  for Docker commands; `adm`, `cdrom`, `dip`, `lxd` are mostly Ubuntu
  defaults you're not actively using. This connects directly to
  Day 2 — group membership is exactly what gets checked whenever the
  system decides if you're allowed to read/write/execute something.
  `id` shows you the keys you're holding; a permissions check is the
  system testing whether one of your keys fits the lock.

`history`'s numbers (e.g. `123  id`) are just a running count of
commands typed this session — not meaningful on their own, but you can
rerun a specific one with `!123` instead of retyping it.

**🌍 In the real world:** `man` pages have existed since Unix's first
release in 1971 — even senior engineers reach for `man <cmd>` or a
cheat-sheet constantly. Nobody memorizes every flag; knowing *how to
look it up fast* is the actual skill.

**🎯 Apply it:** [Bandit level 0](https://overthewire.org/wargames/bandit/)
— the connection details and starting password are right there on the
page. This level is pure navigation, exactly what you just practiced.
Solve it before moving on to Day 2.

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

**🎯 Apply it:** Bandit level 1 — solve it using the password level 0
gave you. Figuring out what today's level actually needs *is* the
exercise; that's true for every level from here on, so this instruction
won't repeat it every day.

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

**🎯 Apply it:** Bandit level 2.

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

**🎯 Apply it:** Bandit level 3 — a good reminder that not everything
useful is visible with a plain `ls`.

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

By now you should be sitting on the password for **Bandit level 4** —
if not, that's worth resolving before Week 2, not after.

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

**Decode it:** this reads exactly like your own `id` output from Day 1
— `trainee`'s primary group (`gid`) is its own private group (Ubuntu's
default behavior for every new user), and `groups` lists that primary
group plus every extra one it's in. Your actual uid number for
`trainee` will just be "next available" on this box, so it may not
match the example above exactly — that's normal, the *shape* of the
output is what matters, same as every day in this course.

**🌍 In the real world:** mismanaged group/permission grants are a
recurring theme in real intrusions and internal data leaks — someone
gets added to a group "just for now" that never gets revoked, or a
script overwrites a group list instead of appending to it (exactly
what `-aG` protects against) and quietly strips someone's real access.

**🎯 Apply it:** Bandit level 4.

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

**Decode it — `ps aux`'s columns, left to right:** `USER` (who owns the
process), `PID` (its unique ID — this is what `kill` targets), `%CPU`
/ `%MEM` (current resource usage), `VSZ`/`RSS` (memory size details,
rarely needed day to day), `TTY` (which terminal it's attached to, or
`?` if none), `STAT` (state — `S` sleeping, `R` running, `Z` a "zombie"
that's finished but not yet cleaned up), `START` (when it began), `TIME`
(actual CPU time used, not wall-clock time), and finally `COMMAND` —
the actual command line that started it, which is usually what you're
scanning for.

**🌍 In the real world:** Knight Capital's infamous 2012 trading
incident — a $440M loss in 45 minutes — was partly caused by an old
process that should never have still been running getting triggered
against live production. "What's actually running right now, and
should it be" is a genuinely load-bearing question in production
systems, not just a sandbox exercise.

**🎯 Apply it:** Bandit level 5.

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

**🎯 Apply it:** Bandit level 6.

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

You should be holding the password for **Bandit level 7** by now.

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

**🎯 Apply it:** Bandit level 7 — `grep` earns its place here.

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

**🎯 Apply it:** Bandit level 8.

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

**🎯 Apply it:** Bandit level 9.

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

**🎯 Apply it:** Bandit level 10 — a good moment to `man` an encoding
tool you haven't used yet rather than guessing.

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

**🎯 Apply it:** Bandit level 11.

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

You should be holding the password for **Bandit level 12** — this next
stretch (12-15 or so) gets noticeably harder and often involves
decompressing files through several layers. Take your time.

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

**🎯 Apply it:** Bandit level 13.

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

**Decode it — `systemctl status docker`'s key lines:** the `●` symbol
at the top is a quick health indicator (green/filled = fine, red = a
problem). `Loaded:` shows where its unit file lives and whether it's
`enabled`. `Active: active (running) since ...` is the line to check
first — it tells you both *whether* it's up and *how long* it's been
up (a service that restarted 30 seconds ago after running fine for
weeks is a strong clue something just went wrong). `Main PID:` links
it back to the `ps aux`/`PID` concept from Day 6 — a service is, under
the hood, just a process systemd is supervising. Below that, a handful
of the most recent log lines are shown inline, so you often don't even
need `journalctl` separately for a quick check.

**🌍 In the real world:** systemd became the default init system across
nearly every major Linux distribution by the mid-2010s (not without
controversy) specifically because "is my service actually running, and
will it restart itself if it dies" needed a real, reliable answer —
silent service death used to be a genuinely common, hard-to-diagnose
cause of downtime.

**🎯 Apply it:** Bandit level 14.

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

**🎯 Apply it:** Bandit level 15.

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

**🎯 Apply it:** Bandit level 16 — this one involves connecting to a
range of ports to find the right one; `nc` or `openssl s_client` are
worth reading up on if you haven't used them yet.

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

You should be holding the password for **Bandit level 17**.

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

**Decode it:**
- **`ip addr`** — look for `ens3` (or similar): `inet 10.0.0.x/24` is
  this machine's own private IP and subnet size. `lo` is the
  "loopback" interface, always `127.0.0.1` — a machine's way of
  talking to itself, used constantly by services on the same box.
- **`ss -tulpn`** columns: `Netid` (`tcp` or `udp`), `State`
  (`LISTEN` = accepting connections), `Local Address:Port` — this is
  the one to actually read: `0.0.0.0:22` means "listening on port 22,
  on *every* network interface"; `127.0.0.1:6010` means "only reachable
  from this machine itself," a meaningfully different (and safer)
  scope. `Process` at the end names exactly which program owns that
  port — the same `PID`/`COMMAND` idea from Day 6's `ps aux`.
- **`dig`'s `ANSWER SECTION`** — the line under this heading is the
  actual result: domain name, a TTL (how long that answer can be
  cached, in seconds), record type (`A` = IPv4 address), and the IP
  itself.

**🌍 In the real world:** the 2021 global outage that took down
Facebook, Instagram, and WhatsApp simultaneously was ultimately a
networking misconfiguration (BGP routing) — the same category of "what
can actually reach what, and why" question you're practicing here,
just playing out at planetary scale instead of one sandbox box.

**🎯 Apply it:** Bandit level 17 — this one has you `diff` two files to
find what changed; a nice pairing with today's "what's actually
different here" theme.

**Optional, if you want more than one platform this week:** search
TryHackMe for a free room on basic networking — a nice comparison point
for how a different platform explains the same ideas.

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

**🎯 Apply it:** Bandit level 18 — this one throws something unexpected
at you the moment you log in; read the problem carefully before
reacting.

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

You should be holding the password for **Bandit level 19**.

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

**🎯 Apply it:** Bandit level 19 — a program running with elevated
privileges hands you a shortcut here, if you can find it.

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

**🎯 Apply it:** Bandit level 20.

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

**🎯 Apply it:** Bandit level 21 — cron shows up again here, from a
different angle than Day 12.

**Optional, if you want a deeper Docker detour this week:** search
KodeKloud for their free Docker labs — multi-stage builds and registry
concepts go beyond what this course covers.

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

You should be holding the password for **Bandit level 22**.

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

**🎯 Apply it:** Bandit level 22 — a cron job is doing something on a
schedule here; go find out what.

**Optional, if you want a second platform this week:** search
TryHackMe for a free room on SSH or Linux security fundamentals —
security-flavored practice pairs well with today's material.

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

**🎯 Apply it:** Bandit level 23 — another cron-adjacent level; the
previous level's answer is your way in here.

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

**Decode it — a `last -x` line like
`ubuntu pts/0  84.203.114.183  Fri Aug 8 19:58 - 22:58 (02:59)`:**
username, then `pts/0` (which terminal session — `pts` means a
"pseudo-terminal," i.e. an SSH/remote session, as opposed to `tty`
which would mean someone physically at the machine), then the IP they
connected *from*, then the login time, logout time, and total session
duration in parentheses. Lines starting with `reboot` or `runlevel`
aren't logins at all — they're the system itself recording a restart,
useful for spotting exactly when this box last rebooted.

**🌍 In the real world:** major breaches — the 2013 Target breach among
them — are very often *detected* well after the fact, purely through
patient log analysis, not caught in real time. Calmly reading logs
after something's already gone wrong is one of the most valuable and
most underrated skills in this entire field.

**🎯 Apply it:** Bandit level 24 — a brute-force-by-script level; this
is a good excuse to write a small loop instead of trying passwords by
hand.

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

You should be holding the password for **Bandit level 25**. From here
through the low 30s, Bandit gets genuinely hard — expect some levels to
take more than one sitting. That's the design, not a sign you're
behind.

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

**🎯 Apply it:** Bandit levels 26 and 27 — 27 involves a git repository
with history worth digging through, foreshadowing Day 27's networking
capstone nicely.

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

**🎯 Apply it:** Bandit levels 28 and 29 — more git archaeology; look
for things that were deleted or changed, not just what's there now.

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

**🎯 Apply it:** Bandit levels 30 and 31 — 31 wants you to interact with
`git` in a way that isn't just `add`/`commit`; read the repository's own
instructions carefully.

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

**🎯 Apply it:** Bandit levels 32 and 33 — the final two. Level 33 is
the last one; solving it means you've finished all 34 levels (0
through 33) of the wargame, entirely spread across this course, one day
at a time.

---

## Week 8 Review — before the final day

1. What three separate skills from earlier weeks combined into Day 26's
   deployment?
2. What's genuinely different about WireGuard compared to older VPN
   protocols like OpenVPN?
3. In Day 28's health-check script, what would `set -e` actually protect
   against?
4. Looking back at Bandit level 0 versus level 33 — what changed about
   *how* you approached an unfamiliar problem, not just what commands
   you used?

---

# Week 9 — Final Skills Test

## Day 29 — One platform, no hand-holding

**Objective:** prove the whole foundation transfers to a platform this
course had no part in building.

**Go here:** [tryhackme.com](https://tryhackme.com/) — search for the
"Linux Fundamentals" room path (free tier). If you sampled a room back
on Day 22, pick up from there; otherwise start fresh.

**Do this:** complete the path, start to finish. Unlike every day
before this one, there's no "Do this" command list — figuring out what
each room needs *is* the exercise, using nothing but 28 days of
built-up instinct. Where it uses a tool this course didn't cover,
that's useful signal, not a gap you failed to close — note it down.

**Come back and tell me:**
- What (if anything) came up that this course never touched.
- Whether it felt meaningfully easier than it would have a month or two
  ago — that comparison is the actual point of this whole day.

**If you want more after this:** OverTheWire has other free wargames in
the same style as Bandit — **Natas** (web application security),
**Leviathan** (beginner-friendly binary/exploitation basics), and
**Krypton** (cryptography puzzles). KodeKloud's free Docker labs are
also worth a fuller pass if Day 21's optional detour interested you.
None of that is required — this course is complete either way.

**Self-check:** none — this one's genuinely unverifiable from here.
Self-report with `course.sh done 29` once you've finished the path.

---

## After this

You've now covered real sysadmin fundamentals end to end — shell,
permissions, environment variables, users, processes, packages, text
wrangling, scripting with real error handling, git, backups, cron,
systemd, networking, firewalls, Docker (including Compose), and
security hardening — plus two real deployed capstones, all 34 levels of
OverTheWire Bandit solved incrementally alongside the material, and a
final proof-it-transfers test on a platform this course didn't write.
That combination — built-here fundamentals *and* proven against
material this project didn't script — is a genuinely solid, credible
foundation. Natural next directions from here: Ansible (automating
server setup itself), a proper CI/CD pipeline, Kubernetes, or one of
the wargames mentioned in Day 29. Ask when you get there.
