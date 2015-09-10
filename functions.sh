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


function get_suffix() {
	if [ -z "$LDAP_SUFFIX" ]; then
		old_ifs=${IFS}
		IFS="."
		for component in $DOMAIN; do
			result="$result,dc=$component"
		done
		IFS="${old_ifs}"
		LDAP_SUFFIX="${result#,}"
	fi
	return 0
}


function ifdev() {
IF=(`cat /proc/net/dev | grep ':' | cut -d ':' -f 1 | tr '\n' ' '`)
}

function firstdev() {
ifdev
LAN_INTERFACE=${IF[1]}
}

function get_domain() {
	if [ "$DOMAIN"="" ]; then
		_DOMAIN_=`$HOSTNAME -d`
		if [ -z "$_DOMAIN_" ]; then
				echo -n "In put server domain [example.com] "
				read _DOMAIN_
				if [ ! -z "$_DOMAIN_" ]; then
					DOMAIN=$_DOMAIN_
				else
					echo "Error: Server domain doesn't exist!"
					exit 1
				fi
		else
			#usamos el dominio configurado del host
			DOMAIN=$_DOMAIN_
		fi
	fi
	return 0
}

function get_hostname() {
	if [ -z "$HOSTNAME_PREFIX" ]; then
		_HOST_=`$HOSTNAME -s`
		if [ -z "$_HOST_" ]; then
			echo -n "Hostname missing: What hostname do you wish for this directory server? [$HOSTNAME_PREFIX]: "
            read _HOSTNAME_
            if [ ! -z "$_HOSTNAME_" ]; then
            	HOSTNAME_PREFIX=$_HOSTNAME_
            else
            	echo "Hostname missing: missing server name"
                exit 1
            fi
        else
        	HOSTNAME_PREFIX=$_HOST_
		fi
	fi
	return 0
}

function servername() {
	get_hostname
	if [ "$?" -ne "0" ]; then
		echo "Error hostname doesn't exist"
		exit 1
	fi
	get_domain
	if [ "$?" -ne "0" ]; then
		echo "Error domain doesn't exist"
		exit 1
	fi	
	SERVERNAME="$HOSTNAME_PREFIX.$DOMAIN"
}

function get_admin_password() {
	echo
	echo "In put a password for service admin"
	echo
	echo "The LDAP service admin login cn is: "
	echo "cn=admin,$LDAP_SUFFIX"
	echo 
	echo "The LDAP cn=config is:"
	echo "cn=admin,cn=config"
	while /bin/true; do
        echo -n "New password: "
        stty -echo
        read pass1
        stty echo
        echo
        if [ -z "$pass1" ]; then
            echo "Error, password cannot be empty"
            echo
            continue
        fi
        echo -n "Repeat new password: "
        stty -echo
        read pass2
        stty echo
        echo
        if [ "$pass1" != "$pass2" ]; then
            echo "Error, passwords don't match"
            echo
            continue
        fi
        PASS="$pass1"
        break
	done
    if [ -n "$PASS" ]; then
        return 0
    fi
    return 1
}

## end functions ####
