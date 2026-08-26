#!/bin/bash
echo "=== Day 13 self-check: git basics ==="
pass=true
repo=~/training/git-practice

if [ -d "$repo/.git" ]; then
  echo "[PASS] git repo exists at $repo"
else
  echo "[FAIL] no git repo found at $repo -- run: mkdir -p $repo && cd $repo && git init"
  pass=false
fi

if $pass; then
  commits=$(git -C "$repo" log --oneline 2>/dev/null | wc -l)
  if [ "$commits" -ge 1 ]; then
    echo "[PASS] $commits commit(s) found"
  else
    echo "[FAIL] no commits found -- run: git add . && git commit -m \"...\""
    pass=false
  fi
fi

if $pass; then echo "All checks passed. Nice work."; else echo "Some checks failed -- see notes above."; fi
