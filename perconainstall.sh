#!/bin/bash
PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

apt install gnupg2 lsb-release
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
apt update
apt-get install percona-server-server-5.7
apt install ufw 
ufw allow mysql
ufe allow ssh
ufw allow 42000:42999/tcp
ufw enable
mysql_secure_installation
clear
while true; do
    read -p "Do you want to install PMM-Clients? y/n-> " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
ufw allow 51999  && ufw allow 42000:42999/tcp
read -p "Enter the admin password-> " pass
read -p "Enter ip address-> " ip
pmm-admin config --server-insecure-tls --server-url=https://admin:$pass@$ip
echo "Client registration is done!"
echo "Creating a dedicated user pmm to monitor and manage Percona"
PASSWDDB="$(openssl rand -base64 32)"
mysql --u root -p <<MYSQL_SCRIPT
Create user 'pmm'@'localhost' identified by '$PASSWDDB';
Grant all privileges on *.* to 'pmm'@'localhost' with grant option;
Flush privileges;
MYSQL_SCRIPT
echo "create user (DB) pmm password-" $PASSWDDB
read -p "Register a server to be monitored, enter the name" namebd
pmm-admin add mysql --username=pmm --password=$PASSWDDB --query-source=perfschema $namebd





