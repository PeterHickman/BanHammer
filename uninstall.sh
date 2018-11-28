#!/bin/sh

if ! [ "$(id -u)" = 0 ]; then
  echo 'You must be root to do this.' 1>&2
  exit 1
fi

remove_file() {
  if [ -r "$1" ]; then
    echo "Removing $1"
    rm -f "$1"
  fi
}

remove_dir() {
  if [ -d "$1" ]; then
    echo "Removing $1"
    rm -rf "$1"
  fi
}

remove_dir /etc/ban_hammer

remove_file /usr/local/sbin/bh
remove_file /cron.daily/banhammer
remove_file /cron.hourly/banhammer
remove_file /cron.weekly/banhammer

remove_file /var/log/ban_hammer*
