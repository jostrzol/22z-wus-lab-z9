#!/bin/sh

if [ "$#" -ne 0 ]; then
    echo "Usage: $0" >&2
    exit 1
fi

sudo sed -i "s/.*server-id.*/server-id = 1/" /etc/mysql/mysql.conf.d/mysqld.cnf;
sudo sed -i "s/.*log_bin.*/log_bin = \\/var\\/log\\/mysql\\/mysql-bi.log/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo mysql -e "CREATE USER 'replication'@'%' IDENTIFIED BY 'haslo'; GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';"

sudo service mysql restart