#!/bin/bash
echo "=== Day 26 self-check: deployed nginx service ==="
pass=true

if systemctl is-active nginx &>/dev/null; then
  echo "[PASS] nginx service is active"
else
  echo "[FAIL] nginx not active -- run: sudo systemctl enable --now nginx"
  pass=false
fi

if curl -sI http://localhost 2>/dev/null | grep -q "200 OK"; then
  echo "[PASS] http://localhost responds with 200 OK"
else
  echo "[FAIL] http://localhost did not return 200 OK"
  pass=false
fi

if sudo ufw status 2>/dev/null | grep -q "80/tcp"; then
  echo "[PASS] port 80/tcp is allowed through the firewall"
else
  echo "[INFO] port 80/tcp not found in ufw rules -- either ufw is inactive (fine) or"
  echo "       you still need: sudo ufw allow 80/tcp"
fi

if $pass; then echo "All checks passed. Nice work -- that's a real deployed service."; else echo "Some checks failed -- see notes above."; fi
