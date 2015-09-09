#!/bin/bash

# Extract archives - use: extract <file>
# Based on http://dotfiles.org/~pseup/.bashrc
function extract() {
if [ -f "$1" ] ; then
local filename=$(basename "$1")
local foldername="${filename%%.*}"
local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
local didfolderexist=false
if [ -d "$foldername" ]; then
didfolderexist=true
read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
return
fi
fi
mkdir -p "$foldername" && cd "$foldername"
case $1 in
*.tar.bz2) tar xjf "$fullpath" ;;
*.tar.gz) tar xzf "$fullpath" ;;
*.tar.xz) tar Jxvf "$fullpath" ;;
*.tar.Z) tar xzf "$fullpath" ;;
*.tar) tar xf "$fullpath" ;;
*.taz) tar xzf "$fullpath" ;;
*.tb2) tar xjf "$fullpath" ;;
*.tbz) tar xjf "$fullpath" ;;
*.tbz2) tar xjf "$fullpath" ;;
*.tgz) tar xzf "$fullpath" ;;
*.txz) tar Jxvf "$fullpath" ;;
*.zip) unzip "$fullpath" ;;
*) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
esac
else
echo "'$1' is not a valid file"
fi
}

function set_mail() {
#Check mail service exist or not~
if [ -f /etc/postfix/main.cf ] ; then
	sudo sed -i "s/myhostname =.*/myhostname = ${HOSTNAME}/;s/mydestination =.*/mydestination = ${HOSTNAME},l
ocalhost/;s/relayhost =.*/relayhost = mail.$(hostname -d)/" /etc/postfix/main.cf
	sudo service postfix reload
	echo -e "Postfix reconfig done!"
else
	echo -e "Install Postfix to ${HOSTNAME}"
	MAIL_SERVER=mail.$(hostname -d)

cat> /tmp/debconf-mailutils.txt <<EOF
postfix	postfix/relayhost	string	${MAIL_SERVER}
postfix	postfix/mailname	string	$(hostname -f)
postfix	postfix/main_mailer_type	select	Satellite system
postfix	postfix/recipient_delim	string	+
postfix	postfix/destinations	string	${HOSTNAME},$(hostname -f) , localhost.localdomain, localhost
postfix	postfix/rfc1035_violation	boolean	false
postfix	postfix/procmail	boolean	false
postfix	postfix/mynetworks	string	127.0.0.0/8
postfix	postfix/mailbox_limit	string	0
postfix	postfix/protocols	select	ipv4
EOF
	cat /tmp/debconf-mailutils.txt |debconf-set-selections
	sudo apt-get -y install mailutils
	rm /tmp/debconf-mailutils.txt
	echo -e "\n${HOSTNAME} Mail service installation done!!!\n"
fi
}
