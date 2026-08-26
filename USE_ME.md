# Using the linux-sandbox

Your personal practice box. Break things on purpose, learn how Linux
actually works, reset whenever you like.

## Connecting

```
ssh -i ~/.ssh/sandbox_oracle ubuntu@143.47.240.110
```

(Or just use your existing MobaXterm saved session — same box.)

You'll see a `neofetch` system summary on login, and your prompt will
say `ubuntu@linux-sandbox`.

## Resetting things — two levels

### Level 1: disposable containers (fast, use this most of the time)

Docker is installed and ready. Every container is a lightweight,
throwaway mini-Linux — install stuff, delete system files, whatever —
and it never touches the real machine underneath.

**One-off experiment, gone when you're done:**
```bash
docker run -it --rm ubuntu bash
```
- `-it` = give you an interactive terminal inside it
- `--rm` = automatically delete the container the moment you exit
- Type `exit` when done — poof, gone, no trace

**Something you want to keep coming back to over several sessions:**
```bash
# create it once
docker run -d --name mybox ubuntu sleep infinity

# hop in anytime (survives you closing SSH / reconnecting later)
docker exec -it mybox bash

# when you're done experimenting for good, clean up
docker stop mybox && docker rm mybox
```
The container keeps running in the background between visits — `exit`
from `docker exec` just leaves the shell, it doesn't stop the container.

**Useful Docker commands:**
```bash
docker ps              # what's currently running
docker ps -a            # everything, including stopped containers
docker images            # what images you've downloaded
docker rm -f mybox      # force-stop and delete in one go
```

### Level 2: full OS reinstall (nuclear option)

If you've truly wrecked the host itself (not just a container) —
Oracle Cloud Console → Compute → Instances → this instance → **Terminate**
or use the reinstall option to get a completely clean Ubuntu install.
This is destructive and wipes everything, including Docker itself, so
it needs to be done deliberately through the Oracle web console, not
something to do casually. Ask your Claude session to walk you through
it if/when you actually need it.

## A couple of things worth knowing

- **`sudo` matters.** You're logged in as `ubuntu`, a normal user, not
  root. Most system-level changes need `sudo` in front of the command.
  This is normal Linux practice, not specific to this box.
- **The `docker` group = root-equivalent.** Your `ubuntu` user is in the
  `docker` group so you don't need `sudo` for Docker commands. That
  convenience comes with a caveat: anyone in the `docker` group can
  effectively get root on the host (containers can be run with the
  host filesystem mounted in). Fine for a single-user sandbox; just
  know it's not a real security boundary.
- **Only `mybox`-style detached containers survive a dropped SSH
  connection.** An `-it --rm` container tied to your terminal session
  dies with the session if your connection drops unexpectedly (not just
  when you type `exit`). Use `-d` + `docker exec` (above) or `byobu`
  (below) for anything you don't want to lose to a flaky connection.
- **`byobu` is installed** if you want to protect an entire terminal
  session (not just Docker) from dropped connections — run `byobu` to
  start one, do your work inside it, and if SSH drops, reconnect and
  run `byobu` again to pick up exactly where you left off.

## Learning the course

There's a full 9-week, 29-day training course in
[LEARNING.md](LEARNING.md) — shell basics through Docker Compose,
security hardening, and real capstone deployments, with "in the real
world" context on every day tying it to actual incidents and practice.
[GLOSSARY.md](GLOSSARY.md) collects every term by week for quick
review. There's no deadline — go at 1 day a week if that's steadier;
any day can be split across two sessions.

Track your progress with the built-in tracker, already set up on the
instance:

```bash
~/training/course.sh status        # progress bar, streak, all 29 days
~/training/course.sh next          # what to do next
~/training/course.sh test 4        # run Day 4's automated self-check
~/training/course.sh done 4        # mark Day 4 complete
~/training/course.sh certificate   # once all 29 are done
```

Every login also shows a one-line reminder of what's next. Or just say
"day N" in a Claude session and it'll walk through that day live with
you.

## If something feels genuinely broken

Bring it back to a fresh Claude Code session in this same project
directory (`c:\Scripts\linux-sandbox`) — the `CLAUDE.md` file there
keeps the full history and setup so a new session can pick things up
without you re-explaining everything.
