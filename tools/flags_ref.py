import html

FLAGS = [
    ("ls", "list files", [
        ("-l", "long format: permissions, owner, size, date"),
        ("-a", "show hidden dotfiles too"),
        ("-h", "human-readable sizes (with -l)"),
        ("-la", "the combo you'll type a thousand times"),
    ]),
    ("chmod", "change permissions", [
        ("644", "owner read+write, everyone else read-only"),
        ("755", "owner full access, everyone else read+execute"),
        ("000", "nobody (not even owner) can do anything"),
        ("+x", "add execute permission, keep everything else"),
    ]),
    ("grep", "search text", [
        ("-i", "case-insensitive match"),
        ("-r", "search recursively through a directory"),
        ("-n", "show line numbers"),
        ("-E", "extended regex: enables | and () without backslashes"),
        ("-v", "invert match — show lines that DON'T match"),
    ]),
    ("sed", "stream editor", [
        ("s/x/y/", "replace first match of x with y, per line"),
        ("s/x/y/g", "replace every match, not just the first"),
        ("-i", "edit the file in place instead of printing"),
    ]),
    ("find", "search the filesystem", [
        ("-name", "match by filename (supports wildcards)"),
        ("-type f / -type d", "files only / directories only"),
        ("-maxdepth N", "don't recurse deeper than N levels"),
        ("-mtime -N", "modified within the last N days"),
    ]),
    ("ps", "list processes", [
        ("aux", "everyone's processes, detailed, even without a terminal"),
        ("-ef", "similar, full-format alternative"),
    ]),
    ("kill", "send a signal to a process", [
        ("(no flag)", "SIGTERM — ask nicely, process can clean up first"),
        ("-9", "SIGKILL — force-stop immediately, no cleanup"),
        ("-l", "list all available signal names"),
    ]),
    ("apt", "package management", [
        ("update", "refresh the list of available versions (installs nothing)"),
        ("install -y", "install, auto-confirming prompts"),
        ("remove", "uninstall, keep config files"),
        ("purge", "uninstall and delete config files too"),
        ("autoremove", "clean up now-unneeded dependencies"),
    ]),
    ("systemctl", "manage services", [
        ("status", "current state + recent logs for a service"),
        ("start / stop", "start or stop right now, no persistence"),
        ("enable / disable", "start automatically on boot, or don't"),
        ("enable --now", "both enable AND start, in one command"),
        ("daemon-reload", "make systemd notice a new/changed unit file"),
    ]),
    ("journalctl", "view systemd logs", [
        ("-u <service>", "logs from just one service"),
        ("-n 20", "last 20 lines"),
        ("-f", "follow live, like tail -f"),
        ("--no-pager", "print and exit instead of opening a pager"),
    ]),
    ("ss", "socket / port statistics", [
        ("-t", "TCP sockets"),
        ("-u", "UDP sockets"),
        ("-l", "listening sockets only"),
        ("-p", "show the owning process"),
        ("-n", "numeric ports, don't resolve service names"),
    ]),
    ("docker run", "start a container", [
        ("-it", "interactive terminal attached"),
        ("-d", "detached — runs in the background"),
        ("--rm", "auto-delete the container when it stops"),
        ("--name", "give it a memorable name instead of a random one"),
        ("-v host:container", "mount a volume or host path"),
        ("-p host:container", "map a port"),
    ]),
    ("docker compose", "multi-container apps", [
        ("up -d", "start everything in the file, detached"),
        ("ps", "status of this project's containers"),
        ("logs <svc>", "logs for one service in the file"),
        ("down", "stop and remove everything started by up"),
    ]),
    ("git", "version control", [
        ("init", "create a new repository"),
        ("add <file>", "stage changes for the next commit"),
        ("commit -m \"...\"", "save a staged snapshot with a message"),
        ("status", "what's changed since the last commit"),
        ("diff", "exact line-by-line changes, unstaged"),
        ("log --oneline", "compact commit history"),
    ]),
    ("tar", "archive files", [
        ("-c", "create an archive"),
        ("-x", "extract an archive"),
        ("-z", "gzip compress/decompress"),
        ("-v", "verbose — list files as it works"),
        ("-f <name>", "the archive filename"),
        ("-C <dir>", "change directory first, for clean relative paths"),
    ]),
    ("rsync", "efficient copying/syncing", [
        ("-a", "archive mode — preserves permissions, timestamps, etc."),
        ("-v", "verbose"),
        ("-n", "dry run — show what would happen, change nothing"),
    ]),
    ("ufw", "firewall frontend", [
        ("status verbose", "current rules and default policy"),
        ("allow 22/tcp", "explicitly allow a port"),
        ("enable / disable", "turn the firewall on or off"),
    ]),
    ("useradd / usermod", "manage users", [
        ("useradd -m", "create the account with a home directory"),
        ("useradd -s /bin/bash", "set the default shell"),
        ("usermod -aG <group>", "APPEND to a group (never drop -a)"),
    ]),
    ("cron", "schedule syntax (5 fields)", [
        ("minute hour dom month dow", "the field order, always"),
        ("* * * * *", "every minute"),
        ("0 3 * * *", "03:00 every day"),
        ("crontab -l / -e / -r", "list / edit / remove your schedule"),
    ]),
]

def render():
    cards = []
    for cmd, desc, flags in FLAGS:
        rows = "".join(
            f'<div class="flag-row"><code>{html.escape(f)}</code><span>{html.escape(m)}</span></div>'
            for f, m in flags
        )
        cards.append(
            f'<div class="flag-card"><div class="flag-card-head"><code class="flag-cmd">{html.escape(cmd)}</code><span class="flag-desc">{html.escape(desc)}</span></div>{rows}</div>'
        )
    return "\n".join(cards)

if __name__ == "__main__":
    print(render())
