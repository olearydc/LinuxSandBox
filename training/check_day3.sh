#!/bin/bash
echo "=== Day 3 self-check: text editors ==="
pass=true

if [ -f ~/notes.txt ] && [ -s ~/notes.txt ]; then
  echo "[PASS] notes.txt exists and has content"
else
  echo "[FAIL] notes.txt missing or empty -- redo the nano exercise"
  pass=false
fi

if [ -f ~/notes2.txt ] && grep -q "hello from vim" ~/notes2.txt 2>/dev/null; then
  echo "[PASS] notes2.txt exists and contains the expected vim text"
else
  echo "[FAIL] notes2.txt missing or doesn't contain 'hello from vim' -- redo the vim exercise"
  pass=false
fi

if $pass; then echo "All checks passed. Nice work."; else echo "Some checks failed -- see notes above."; fi
