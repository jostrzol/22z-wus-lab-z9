#!/usr/bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 DB server ip address" >&2
  exit 1
fi

# Get Packages
sudo apt update -y
sudo apt install -y git openjdk-11-jdk

# Get petclinic rest api
cd || exit
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest || exit

# Set spring DB properties
export SPRING_DATASOURCE_URL="jdbc:mysql://$1:3306/petclinic?useUnicode=true"
export SPRING_PROFILES_ACTIVE=mysql,spring-data-jpa

# Start petclinic rest api
./mvnw spring-boot:run