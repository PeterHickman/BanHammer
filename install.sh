#!/bin/sh

WHITELIST='/etc/ban_hammer/whitelist'
BLACKLIST='/etc/ban_hammer/blacklist'

create_blank() {
  if [ -r $1 ]; then
    echo "File $1 already exists"
  else
    echo "Creating blank file: $1"
    touch $1
  fi
}

if ! [ $(id -u) = 0 ]; then
  echo 'You must be root to do this.' 1>&2
  exit 1
fi

echo 'Installing Ban Hammer for ufw to /usr/local/sbin/'
install -g root -o root -m 0700 bh /usr/local/sbin/

if [ -d '/etc/ban_hammer' ]; then
  echo 'Directory /etc/ban_hammer already exists'
else
  echo 'Creating directory in /etc'
  mkdir -p /etc/ban_hammer
fi	

create_blank $WHITELIST
create_blank $BLACKLIST

echo
echo "Make sure that you populate $WHITELIST"
echo "with a list of the addresses you never"
echo "want to be banned"
