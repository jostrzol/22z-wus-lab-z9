#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 MASTER_ADDRESS MASTER_PORT" >&2
    exit 1
fi

MASTER_ADDRESS="$1"
MASTER_PORT="$2"

sudo sed -i "s/.*server-id.*/server-id = 2/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo mysql -e "CHANGE MASTER TO MASTER_HOST='$MASTER_ADDRESS', MASTER_USER='replikacja', MASTER_PASSWORD='haslo', MASTER_PORT=$MASTER_PORT;"

sudo service mysql restart
sudo mysql -e "start slave;"