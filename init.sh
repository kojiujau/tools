#!/bin/bash

sudo apt-get update
sudo apt-get -y install unzip
wget http://192.168.11.1/~kec/bin/default/env.sh
sudo bash env.sh
wget http://192.168.11.1/~kec/bin/default/top_ldap-preseed.sh
sudo bash top_ldap-preseed.sh
wget http://192.168.11.1/~kec/bin/default/change_em_gw.sh
sudo bash change_em_gw.sh
echo "setting root ssh default login password"
sudo echo 'root:y' | chpasswd
sudo sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
sudo service ssh reload
sudo sed -i "s/myhostname =.*/myhostname = $HOSTNAME/;s/mydestination =.*/mydestination = $HOSTNAME,localhost/;s/relayhost =.*/relayhost = mail.ematters.com.tw/" /etc/postfix/main.cf
sudo service postfix reload
