#!/bin/bash
echo "=== Day 14 self-check: firewall (read-only, makes no changes) ==="

status=$(sudo ufw status 2>/dev/null)
echo "$status"
echo
if echo "$status" | grep -q "inactive"; then
  echo "ufw is currently INACTIVE -- nothing is being blocked at the firewall level."
  echo "This is expected if you've only done the status-check exercise so far."
else
  echo "ufw is ACTIVE. Check the rule list above -- port 22/tcp (SSH) should be"
  echo "explicitly allowed. If it isn't, do NOT enable further changes without"
  echo "fixing that first, or you risk locking yourself out."
fi
