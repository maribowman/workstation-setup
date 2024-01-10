#!/bin/bash

for file in cron/*.sh; do
  cp -a "$file" /etc/cron.d/
  chmod +x /etc/cron.d/"$(basename -- "$file")"

  crontab -l >new_crontab
  echo "@reboot $file" >>new_crontab
  crontab crontab_new

  rm crontab_new
done

# run weekly database backups
# @weekly tar -zcf /var/backups/home.tgz /home/
