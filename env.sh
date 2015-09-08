#!/bin/bash

cron_spool_dir='/var/spool/cron/crontabs'

# time setting
time_setting(){
mv /etc/localtime /etc/localtime.orig
cp -ap /usr/share/zoneinfo/ROC /etc/localtime
cat >> ${cron_spool_dir}/root <<EOF
2   5   *   *   *   ntpdate -s time.konwen.com
EOF
chmod 0600 ${cron_spool_dir}/root
}

# history
history_format(){
cat >> /etc/bash.bashrc <<EOF
## Added by kec@20141015
HISTFILESIZE=4000
HISTSIZE=4000
HISTTIMEFORMAT='%F %T '
export HISTTIMEFORMAT
EOF
}

time_setting
history_format
