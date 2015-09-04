#!/bin/bash
#This script is for synology nas with ssh login without password.
#So,make sure you can login synology nas device via ssh use authentication key.

nas_ip=192.168.11.222
target_nas="sa@${nas_ip}"
mail_to="sa@ematters.com.tw"
now=$(date +%Y-%m-%d-%H%M)
nas_path=/root/backup
local_path=/backups/nas
SSH=/usr/bin/ssh
SCP=/usr/bin/scp


ping -c1 ${nas_ip}
host_status=$?
if [ ${host_status} == 0 ] ; then
	${SSH} ${target_nas} synoconfbkp export --filepath=/${nas_path}/${now}.dss
	${SSH} ${target_nas} "find ${nas_path} -mtime +15 -exec rm -f {} \;"
	${SSH} ${target_nas} "find ${nas_path} -exec ls -l {} \;"
	${SCP} ${target_nas}:${nas_path}/${now}.dss ${local_path}
	find ${local_path} -mtime +30 -exec rm -f {} \;
	echo -e "${target_nas} backup done and config file in ${nas_ip}:/${nas_path}/${now}.dss"|mail -s "NAS ${nas_ip} config backup done" ${mail_to}
else
	echo -e "${target_nas} doesn't exist"|mail -s "NAS ${nas_ip} backup failed" ${mail_to}
fi
