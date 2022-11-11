#!/usr/bin/sh

if [ "$#" -ne 1 ] || ! [ -d "$1" ]; then
  echo "Usage: $0 DB URL" >&2
  exit 1
fi

# spring.datasource.url
export SPRING_DATASOURCE_URL="$1"
export SPRING_PROFILES_ACTIVE=mysql,spring-data-jpa

apt update -y
apt install -y git openjdk-11-jdk
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest || exit

./mvnw spring-boot:run