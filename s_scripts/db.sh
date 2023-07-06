#!/usr/bin/env bash
#
systemctl enable cron
(crontab -l 2>/dev/null; echo "*/2 * * * * /root/s_scripts/host-config.sh >/dev/null 2>&1") | crontab -