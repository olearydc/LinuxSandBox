#!/bin/bash
echo "=== Day 4 self-check: environment variables and PATH ==="

if grep -q "TRAINING_ENV" ~/.bashrc 2>/dev/null; then
  echo "[PASS] TRAINING_ENV export found in ~/.bashrc"
else
  echo "[FAIL] TRAINING_ENV not found in ~/.bashrc -- run:"
  echo "       echo 'export TRAINING_ENV=\"sandbox\"' >> ~/.bashrc && source ~/.bashrc"
  exit 0
fi

val=$(grep "TRAINING_ENV" ~/.bashrc | tail -1 | sed -E 's/.*TRAINING_ENV="?([^"]*)"?.*/\1/')
if [ "$val" = "sandbox" ]; then
  echo "[PASS] TRAINING_ENV is set to 'sandbox' as expected"
  echo "All checks passed. Nice work."
else
  echo "[INFO] TRAINING_ENV found but value is '$val', expected 'sandbox'"
fi
