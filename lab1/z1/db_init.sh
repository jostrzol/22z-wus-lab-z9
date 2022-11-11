#!/bin/sh

DB_SCRIPTS_URI="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql"

# Get packages
apt update -y
apt install -y mysql-server wget

# Configure and start mysql server
sed 's/\(^bind-address\s*=\).*$/\1 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf -i
service mysql start

# Initialize database
mysql -e "CREATE USER 'pc'@'%' IDENTIFIED BY 'petclinic'; GRANT ALL PRIVILEGES ON *.* TO 'pc'@'%' WITH GRANT OPTION;"
wget "$DB_SCRIPTS_URI/initDB.sql" && mysql -f <"initDB.sql"
wget "$DB_SCRIPTS_URI/populateDB.sql" && mysql petclinic -f <"populateDB.sql"