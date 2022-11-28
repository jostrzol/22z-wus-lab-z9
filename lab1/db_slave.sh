#!/bin/sh

sudo sed "s/\\(^server-id\\s*=\\).*$/\\1 2/" /etc/mysql/mysql.conf.d/mysqld.cnf -i;
