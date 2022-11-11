#!/bin/sh

apt update -y
apt install -y mysql-server

sed 's/\(^bind-address\s*=\).*$/\1 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf -i
service mysql start

mysql -e "CREATE DATABASE petclinic"
mysql -e "CREATE USER 'pc'@'%' IDENTIFIED BY 'petclinic'; GRANT ALL PRIVILEGES ON *.* TO 'pc'@'%' WITH GRANT OPTION;"