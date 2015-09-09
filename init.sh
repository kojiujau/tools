#!/bin/bash

sudo apt-get update
sudo apt-get -y install unzip
wget http://192.168.11.1/~kec/bin/default/env.sh
sudo bash env.sh
#wget http://192.168.11.1/~kec/bin/default/top_ldap-preseed.sh
#sudo bash top_ldap-preseed.sh
wget http://192.168.11.1/~kec/bin/default/change_em_gw.sh
sudo bash change_em_gw.sh
echo "setting root ssh default login password"
sudo echo 'root:y' | chpasswd
sudo sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
sudo service ssh reload

if [ -f /etc/postfix/main.cf ] ; then
	sudo sed -i "s/myhostname =.*/myhostname = ${HOSTNAME}/;s/mydestination =.*/mydestination = ${HOSTNAME},localhost/;s/relayhost =.*/relayhost = mail.$(hostname -d)/" /etc/postfix/main.cf
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
	#rm /tmp/debconf-mailutils.txt
	echo -e "\n${HOSTNAME} Mail service installation done!!!\n"
fi


