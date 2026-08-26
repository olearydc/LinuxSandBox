#!/bin/bash
echo "=== Day 14 self-check: systemd and services ==="

active=$(systemctl is-active docker 2>/dev/null)
enabled=$(systemctl is-enabled docker 2>/dev/null)

echo "docker service is-active:  $active"
echo "docker service is-enabled: $enabled"
echo
echo "Compare this to your own answer:"
echo "  'active' means it is running right now."
echo "  'enabled' means it is set to start automatically on the next boot."
echo "  These are independent -- a service can be one, both, or neither."
echo
echo "Last 5 log lines for docker:"
sudo journalctl -u docker -n 5 --no-pager 2>/dev/null
