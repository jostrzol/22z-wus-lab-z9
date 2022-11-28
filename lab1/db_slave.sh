#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 MASTER_ADDRESS" >&2
    exit 1
fi

MASTER_ADDRESS="$1"

sudo sed -i "s/.*server-id.*/server-id = 2/" /etc/mysql/mysql.conf.d/mysqld.cnf;

CHANGE MASTER TO MASTER_HOST="$MASTER_ADDRESS", MASTER_USER='replikacja', MASTER_PASSWORD='haslo';

sudo service mysql restart