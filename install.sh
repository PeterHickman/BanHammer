#!/bin/sh

if ! [ "$(id -u)" = 0 ]; then
  echo 'You must be root to do this.' 1>&2
  exit 1
fi

##
# When installing we would install as root, however on
# BSD based systems (such as OSX) this is not a valid
# group / user for install so we use the numberic value
##
ROOT="0"

WHITELIST='/etc/ban_hammer/whitelist'
BLACKLIST='/etc/ban_hammer/blacklist'

create_blank() {
  if [ -r "$1" ]; then
    echo "File $1 already exists"
  else
    echo "Creating blank file: $1"
    touch "$1"
  fi
}

populate_whitelist() {
  COUNT=`ifconfig | grep -c 'inet addr:'`

  echo '# Make sure we dont ban ourselves, that would be silly' >> /etc/ban_hammer/whitelist

  if [ "$COUNT" = "0" ]; then
    ifconfig | awk '/inet / { split($0, a, " "); split(a[2], b, " "); print b[1] }' >> /etc/ban_hammer/whitelist
  else
    ifconfig | awk '/inet add/ { split($0, a, ":"); split(a[2], b, " "); print b[1] }' >> /etc/ban_hammer/whitelist
  fi

  echo '# Done' >> /etc/ban_hammer/whitelist
}

install_cron() {
  echo "Installing cron into $1"
  install -g $ROOT -o $ROOT -m 0755 "$1" "/etc/$1/banhammer"
}

echo 'Installing Ban Hammer for ufw to /usr/local/sbin/'
install -g $ROOT -o $ROOT -m 0700 bh /usr/local/sbin/

if [ -d '/etc/ban_hammer' ]; then
  echo 'Directory /etc/ban_hammer already exists'
else
  echo 'Creating directory in /etc'
  mkdir -p /etc/ban_hammer
fi

create_blank $WHITELIST
create_blank $BLACKLIST

test -s /etc/ban_hammer/whitelist

if [ $? = "1" ]; then
  populate_whitelist
fi

install_cron cron.daily
install_cron cron.hourly
install_cron cron.weekly

echo "Install the logrotate file"
install -g $ROOT -o $ROOT -m 0644 logrotate /etc/logrotate.d/ban_hammer

echo
echo "Make sure that you populate $WHITELIST"
echo "with a list of the addresses you never"
echo "want to be banned"
