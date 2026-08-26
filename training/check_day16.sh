#!/bin/bash
echo "=== Day 16 self-check: backups (tar / rsync) ==="

backups=$(ls ~/training/backup-*.tar.gz 2>/dev/null | wc -l)
if [ "$backups" -ge 1 ]; then
  echo "[PASS] found $backups backup archive(s) in ~/training/"
  ls -lh ~/training/backup-*.tar.gz
  echo "All checks passed. Nice work."
else
  echo "[FAIL] no backup-*.tar.gz found in ~/training/ -- run the Day 16 tar exercise"
fi
