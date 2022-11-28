#!/bin/sh

sudo sed "s/\\(^server-id\\s*=\\).*$/\\1 1/" /etc/mysql/mysql.conf.d/mysqld.cnf -i;
sudo sed "s/\\(^log_bin\\s*=\\).*$/\\1 /var/log/mysql/mysql-bin.log/" /etc/mysql/mysql.conf.d/mysqld.cnf -i;

