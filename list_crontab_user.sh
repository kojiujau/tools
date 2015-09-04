#!/bin/bash

#for user in $(cut -f1 -d: /etc/passwd); do echo $user; crontab -u $user -l; done
for user in $(cut -f1 -d: /etc/passwd); do echo $user; crontab -u $user -l 2>/dev/null | grep -v '^#'; done|mail -s "$HOSTNAME all user cron
tab" sa@ematters.com.tw -- -f kec@ematters.com.tw
