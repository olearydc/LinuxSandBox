#!/bin/bash
echo "=== Day 12 self-check: cron ==="

cron_active=$(crontab -l 2>/dev/null | grep -c "cron_log.txt")
if [ "$cron_active" -gt 0 ]; then
  echo "[PASS] a crontab entry writing to cron_log.txt is currently active"
  echo "       (remember to run 'crontab -r' when you're done, or it'll run forever)"
elif [ -f ~/training/cron_log.txt ] && [ -s ~/training/cron_log.txt ]; then
  echo "[INFO] no active crontab entry right now, but cron_log.txt has content --"
  echo "       looks like you already did the exercise and cleaned up with 'crontab -r'. Good."
  echo "       Last few lines:"
  tail -3 ~/training/cron_log.txt
else
  echo "[FAIL] no active crontab entry and no cron_log.txt found -- redo the exercise:"
  echo "       echo '* * * * * echo \"cron ran at \$(date)\" >> ~/training/cron_log.txt' | crontab -"
fi
