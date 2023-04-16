#!/bin/bash

# add github to the list of known_hosts addresses
HOSTNAME=git@github.com
KNOWNHOSTS=~/.ssh/known_hosts
ssh-keygen -F $HOSTNAME -f $KNOWNHOSTS | grep -q found || ssh-keyscan $HOSTNAME >>$KNOWNHOSTS 2>/dev/null

# clone github repository code 
git clone --single-branch --branch develop git@github.com:rMiccolis/binanceB.git
chmod u+x binanceB/bin/1-init.sh
