#!/bin/bash
echo "=== Day 9 self-check: shell scripting ==="
pass=true
script=~/training/myscript.sh

if [ -f "$script" ]; then
  echo "[PASS] $script exists"
else
  echo "[FAIL] $script not found"
  pass=false
fi

if [ -x "$script" ]; then
  echo "[PASS] $script is executable"
else
  echo "[FAIL] $script is not executable -- run: chmod +x $script"
  pass=false
fi

if $pass; then
  echo "Running it now to confirm it actually works..."
  rm -rf ~/demo
  cd ~ && "$script"
  if [ -d ~/demo ] && [ "$(ls ~/demo | wc -l)" -eq 3 ]; then
    echo "[PASS] script created ./demo with 3 files as expected"
  else
    echo "[FAIL] script ran but ./demo doesn't have exactly 3 files"
    pass=false
  fi
fi

if $pass; then echo "All checks passed. Nice work."; else echo "Some checks failed -- see notes above."; fi
