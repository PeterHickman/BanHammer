# BanHammer

We use `ufw` to manage `iptables` on a few of our servers. Whilst it does a good job we use it so occasionally that the syntax is just as obscure as `iptables` itself. So this little wrapper allows us to manage banning the naughty ip addresses

Requires Ruby >= 1.9.3 and, of course, `ufw`

## Install

Run the `install.sh` script and `bh` will be installed to `/usr/local/sbin`, a directory created - `/etc/ban_hammer` and two configuration files

* `/etc/ban_hammer/whitelist` This contains the list of addresses that we never want to ban. Even if we issue the command to ban them. Note that the addresses must be one per line, single addresses (such as `X.X.X.X`) and not ranges
* `/etc/ban_hammer/blacklist` This will be populated by the `bh` script with the addresses to be banned along with the date they were banned or reported

## Usage

### `show`

	# bh show
	Whitelist (/etc/ban_hammer/whitelist)
	- X.X.X.X
	
	Blacklist (/etc/ban_hammer/blacklist)
	- 206.189.125.14
	- 5.135.181.112
	- 79.19.119.188
	- 79.181.227.42
	- 13.57.222.62
	- 36.189.253.232

Shows the whitelisted addresses and the blacklisted addresses

### `update`

	# bh update
	Checking that ufw is up to date
	-- 187.141.143.180 was missing
	-- 106.38.59.5 was missing
	-- 172.81.224.196 was missing
	There are 714 banned addresses, 3 were missing

Goes over the blacklist and makes sure that all the addresses are being blocked by `ufw`

### `add X.X.X.X`

	# bh add X.X.X.X
	X.X.X.X added to blacklist

Adds a given ip address to the blacklist and gets `ufw` to block it. Unless:

1. If the address is in the whitelist it will not be banned and you will be told
2. If the address is already being banned. The timestamp against the address will be updated

### `remove X.X.X.X`

	# bh remove X.X.X.X
	X.X.X.X removed from blacklist

Removes the given ip address from the blacklist and get `ufw` to forget it. It will also remove the address from `ufw` even if it is not in the blacklist (in case someone blocked it without `bh`)

### `import ufw <filename>`

Filters the ufw.log file and gets a list of addresses that were blocked. If any of the addresses are already in the blacklist then their timestamp is bumped

### `import auth <filename>`

Filter the auth.log file and find out who has been grinding at the ssh service and ban them. Only actually ban them when they hit > 100 attempts

## Using it

The initial population of the blacklist can come from the `import auth /var/log/auth.log` command followed, perhaps, with a daily cron task to keep it up to date. Similary a cron to run `import ufw /var/log/ufw.log` will make sure that we are keeping up to date with the repeat offenders

Another good source of miscreants are the various web server logs. However this is more site specific so I have no general script to offer at this point that won't generate false positives

Each time an address is banned it's timestamp is incremented so addresses with older timestamps have either been cleaned up, gone offline or given up and can be removed from the blacklist. Otherwise it would simply get too damn big

I plan to implement a `purge X` command to purge blacklisted addresses that haven't been seen in `X` days

## To Do

1. Implement the purge command
2. Display usage when no command is given
3. Update should check if we are blocking whitelisted addresses
