#!/bin/sh

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 MY_PORT DB_MASTER_ADDRESS DB_MASTER_PORT DB_SLAVE_ADDRESS DB_SLAVE_PORT" >&2
    exit 1
fi

MY_PORT="$1"
DB_MASTER_ADDRESS="$2"
DB_MASTER_PORT="$3"
DB_SLAVE_ADDRESS="$4"
DB_SLAVE_PORT="$5"

# Get Packages
sudo apt update -y
sudo apt install -y git openjdk-11-jdk

# Get petclinic rest api
cd || exit
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest || exit

# Set spring
export SPRING_DATASOURCE_URL="jdbc:mysql:replication://$DB_MASTER_ADDRESS:$DB_MASTER_PORT,$DB_SLAVE_ADDRESS,$DB_SLAVE_PORT/petclinic?useUnicode=true&allowSourceDownConnections=true"
export SPRING_PROFILES_ACTIVE=mysql,spring-data-jpa
export SERVER_PORT="$MY_PORT"

# Start petclinic rest api in background
./mvnw spring-boot:run &
