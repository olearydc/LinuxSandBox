#!/bin/bash
echo "=== Day 12 self-check: custom systemd service ==="
pass=true

if [ -f /etc/systemd/system/heartbeat.service ]; then
  echo "[PASS] heartbeat.service unit file exists"
else
  echo "[FAIL] /etc/systemd/system/heartbeat.service not found"
  pass=false
fi

if systemctl is-active heartbeat &>/dev/null; then
  echo "[PASS] heartbeat service is active"
else
  echo "[FAIL] heartbeat service is not active -- run: sudo systemctl enable --now heartbeat"
  pass=false
fi

if [ -f ~/training/heartbeat.log ] && [ -s ~/training/heartbeat.log ]; then
  lines=$(wc -l < ~/training/heartbeat.log)
  echo "[PASS] heartbeat.log has $lines line(s) -- service is actually doing its job"
else
  echo "[FAIL] heartbeat.log missing or empty"
  pass=false
fi

if $pass; then
  echo "All checks passed. Remember to clean up when you're done exploring:"
  echo "  sudo systemctl disable --now heartbeat"
  echo "  sudo rm /etc/systemd/system/heartbeat.service && sudo systemctl daemon-reload"
else
  echo "Some checks failed -- see notes above."
fi
