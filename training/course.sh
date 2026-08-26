#!/bin/bash
# Course tracker for the Linux Learning Path (LEARNING.md).
# Usage:
#   course.sh status          -- show progress, streak, and progress bar (planner)
#   course.sh done <N>        -- mark day N complete, updates streak (marker)
#   course.sh undone <N>      -- unmark day N
#   course.sh test <N>        -- run day N's self-check, if one exists (tester)
#   course.sh next            -- show the next incomplete day
#   course.sh certificate     -- print a completion certificate once all days are done

PROGRESS_FILE=~/training/progress.txt
STREAK_FILE=~/training/streak.txt
touch "$PROGRESS_FILE"

TITLES=(
  "" # index 0 unused, days are 1-indexed
  "Finding your way around"
  "Files, permissions, ownership"
  "Text editors: nano and vim"
  "Environment variables and PATH"
  "Users and groups"
  "Processes"
  "Installing software"
  "Pipes, grep, and find"
  "Regex basics with grep and sed"
  "Shell scripting basics"
  "Bash error handling: set -e and trap"
  "Scheduling with cron"
  "Git basics"
  "systemd and services"
  "Write your own systemd service"
  "Backups: tar and rsync"
  "Networking basics"
  "Firewall"
  "Building your own images"
  "Volumes and networks"
  "Docker Compose: multi-container apps"
  "SSH and basic hardening"
  "fail2ban: automated intrusion protection"
  "Reading the trail: logs and auditing"
  "Mini investigation"
  "Capstone: deploy a real service"
  "Capstone: WireGuard VPN"
  "Capstone: tie it all together"
  "External mastery: finish Bandit (26-34)"
  "External mastery: finish TryHackMe Linux Fundamentals"
  "External mastery: finish KodeKloud Docker labs"
  "Where to go from here"
)
TOTAL=$((${#TITLES[@]} - 1))

is_done() { grep -qxF "$1" "$PROGRESS_FILE" 2>/dev/null; }

progress_bar() {
  local done_count=$1 total=$2 width=30
  local filled=$(( done_count * width / total ))
  local empty=$(( width - filled ))
  printf "["
  [ "$filled" -gt 0 ] && printf "%0.s#" $(seq 1 $filled)
  [ "$empty" -gt 0 ] && printf "%0.s-" $(seq 1 $empty)
  printf "] %d%%\n" $(( done_count * 100 / total ))
}

update_streak() {
  local today last streak=0
  today=$(date +%Y-%m-%d)
  if [ -f "$STREAK_FILE" ]; then
    read -r last streak < "$STREAK_FILE"
  fi
  if [ "$last" = "$today" ]; then
    : # already counted today
  elif [ "$last" = "$(date -d yesterday +%Y-%m-%d 2>/dev/null)" ]; then
    streak=$((streak + 1))
  else
    streak=1
  fi
  echo "$today $streak" > "$STREAK_FILE"
}

current_streak() {
  [ -f "$STREAK_FILE" ] && awk '{print $2}' "$STREAK_FILE" || echo 0
}

case "$1" in
  status)
    done_count=0
    echo "=== Linux Learning Path: progress ==="
    for i in $(seq 1 $TOTAL); do
      if is_done "$i"; then
        mark="[x]"
        done_count=$((done_count + 1))
      else
        mark="[ ]"
      fi
      printf "%s Day %-2d %s\n" "$mark" "$i" "${TITLES[$i]}"
    done
    echo
    progress_bar "$done_count" "$TOTAL"
    echo "$done_count / $TOTAL days complete."
    streak=$(current_streak)
    if [ "$streak" -gt 0 ]; then
      echo "Current streak: $streak day(s) active. Keep it slow and steady."
    fi
    ;;

  next)
    for i in $(seq 1 $TOTAL); do
      if ! is_done "$i"; then
        echo "Next up: Day $i - ${TITLES[$i]}"
        exit 0
      fi
    done
    echo "All $TOTAL days marked complete. Run 'course.sh certificate'."
    ;;

  done)
    n="$2"
    if [ -z "$n" ] || [ "$n" -lt 1 ] || [ "$n" -gt "$TOTAL" ]; then
      echo "Usage: course.sh done <1-$TOTAL>"; exit 1
    fi
    is_done "$n" || echo "$n" >> "$PROGRESS_FILE"
    update_streak
    echo "Marked Day $n (${TITLES[$n]}) as done."
    ;;

  undone)
    n="$2"
    if [ -z "$n" ]; then echo "Usage: course.sh undone <N>"; exit 1; fi
    sed -i "/^${n}\$/d" "$PROGRESS_FILE"
    echo "Marked Day $n as not done."
    ;;

  test)
    n="$2"
    if [ -z "$n" ]; then echo "Usage: course.sh test <N>"; exit 1; fi
    script=~/training/check_day${n}.sh
    if [ -f "$script" ]; then
      bash "$script"
    else
      echo "No automated self-check for Day $n (${TITLES[$n]})."
      echo "Some days are exploratory/discussion-based by design -- once you've"
      echo "done the exercises and can answer the 'Check yourself' question,"
      echo "mark it done yourself: course.sh done $n"
    fi
    ;;

  certificate)
    done_count=$(grep -c . "$PROGRESS_FILE" 2>/dev/null || echo 0)
    if [ "$done_count" -lt "$TOTAL" ]; then
      echo "Not yet -- $done_count / $TOTAL days complete. Run 'course.sh status' to see what's left."
      exit 0
    fi
    cat <<'EOF'
   *****************************************
   *                                       *
   *        LINUX LEARNING PATH            *
   *         CERTIFICATE OF COMPLETION     *
   *                                       *
   *****************************************

   Awarded to: the linux-sandbox admin

   For completing all 32 days: shell fundamentals,
   permissions, environment variables, users, processes,
   packages, text wrangling, scripting with real error
   handling, git, cron, systemd, backups, networking,
   firewalls, Docker (incl. Compose), SSH hardening,
   fail2ban, log auditing, real deployed capstones, and
   full completion of OverTheWire Bandit, TryHackMe Linux
   Fundamentals, and the KodeKloud Docker labs.

   Slow and steady. Well earned.
EOF
    echo "   Completed: $(date +%Y-%m-%d)"
    ;;

  *)
    echo "Linux Learning Path course tracker"
    echo "Usage:"
    echo "  course.sh status        show progress, streak, and progress bar"
    echo "  course.sh next          show the next incomplete day"
    echo "  course.sh test <N>      run Day N's self-check script, if one exists"
    echo "  course.sh done <N>      mark Day N complete"
    echo "  course.sh undone <N>    unmark Day N"
    echo "  course.sh certificate   print a completion certificate (once all 24 are done)"
    ;;
esac
