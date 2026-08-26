#!/bin/bash
echo "=== Day 7 self-check: package management ==="

if dpkg -l | grep -q "^ii  cowsay"; then
  echo "[PASS] cowsay is installed"
  echo "       (which cowsay -> $(which cowsay))"
else
  echo "[INFO] cowsay is not currently installed."
  echo "       If you already did the exercise and removed it afterward, that's fine --"
  echo "       this just confirms it's not still sitting there. If you haven't done"
  echo "       the exercise yet, run: sudo apt install -y cowsay && cowsay 'hello sandbox'"
fi
