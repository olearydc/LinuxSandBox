#!/bin/bash
echo "=== Day 19 self-check: fail2ban ==="
pass=true

if dpkg -l | grep -q "^ii  fail2ban"; then
  echo "[PASS] fail2ban is installed"
else
  echo "[FAIL] fail2ban not installed -- run: sudo apt install -y fail2ban"
  pass=false
fi

if systemctl is-active fail2ban &>/dev/null; then
  echo "[PASS] fail2ban service is active"
else
  echo "[FAIL] fail2ban not active -- run: sudo systemctl enable --now fail2ban"
  pass=false
fi

if $pass; then
  echo
  echo "Current sshd jail status:"
  sudo fail2ban-client status sshd 2>/dev/null
  echo "All checks passed."
else
  echo "Some checks failed -- see notes above."
fi
