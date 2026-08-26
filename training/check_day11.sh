#!/bin/bash
echo "=== Day 11 self-check: bash error handling (set -e / trap) ==="
pass=true
script=~/training/safe_script.sh

if [ -f "$script" ]; then
  echo "[PASS] $script exists"
else
  echo "[FAIL] $script not found -- create it per the Day 11 exercise"
  pass=false
fi

if $pass && grep -q "set -e" "$script"; then
  echo "[PASS] $script contains 'set -e'"
else
  echo "[FAIL] $script doesn't contain 'set -e'"
  pass=false
fi

if $pass; then echo "All checks passed. Nice work."; else echo "Some checks failed -- see notes above."; fi
