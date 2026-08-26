#!/bin/bash
echo "=== Day 21 self-check: Docker Compose ==="
pass=true

cd ~/training/compose-demo 2>/dev/null || { echo "[FAIL] ~/training/compose-demo not found"; exit 1; }

running=$(docker compose ps --status running 2>/dev/null | grep -c -E "web|redis")
if [ "$running" -ge 2 ]; then
  echo "[PASS] both web and redis services are running"
else
  echo "[FAIL] expected both 'web' and 'redis' running -- run: docker compose up -d"
  pass=false
fi

if curl -sI http://localhost:8080 2>/dev/null | grep -q "200 OK"; then
  echo "[PASS] nginx (web) responded with 200 OK on port 8080"
else
  echo "[FAIL] http://localhost:8080 didn't respond as expected"
  pass=false
fi

if $pass; then
  echo "All checks passed. Remember to clean up when done: docker compose down"
else
  echo "Some checks failed -- see notes above."
fi
