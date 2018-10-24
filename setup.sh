#!/bin/sh

# A script to set the initial values of the blacklist and
# whitelist from the DENY and ALLOW entries in the current
# ufw configuration

TS=$(date "+%s")

echo "Entries for the blacklist"
ufw status | awk "/DENY/ { print \$NF \" \" $TS }" > blacklist

echo "Entries for the whitelist"
ufw status | awk '/ALLOW/ { if ( index($NF, ".") != 0 ) { print $NF }}' > whitelist

echo
echo "The files blacklist and whitelist have been created from"
echo "the current values in ufw. Please review them before copying"
echo "them to /etc/ban_hammer"
