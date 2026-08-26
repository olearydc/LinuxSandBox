#!/bin/bash
echo "=== Day 5 self-check: users and groups ==="
pass=true

if id trainee &>/dev/null; then
  echo "[PASS] user 'trainee' exists"
else
  echo "[FAIL] user 'trainee' not found -- run: sudo useradd -m -s /bin/bash trainee"
  pass=false
fi

if getent group learners &>/dev/null; then
  echo "[PASS] group 'learners' exists"
else
  echo "[FAIL] group 'learners' not found -- run: sudo groupadd learners"
  pass=false
fi

if id trainee 2>/dev/null | grep -q learners; then
  echo "[PASS] trainee is a member of learners"
else
  echo "[FAIL] trainee is not in learners -- run: sudo usermod -aG learners trainee"
  pass=false
fi

if $pass; then echo "All checks passed. Nice work."; else echo "Some checks failed -- see notes above."; fi
