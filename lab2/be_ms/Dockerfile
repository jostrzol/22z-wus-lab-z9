# REQUIRED ENVIRONMENT VARIABLES:
# * DB_ADDRESS
# * DB_PORT

# WILL RUN ON PORT 8081

FROM maven:3.8.6-eclipse-temurin-11-alpine as build-env

RUN apk add git
RUN git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
WORKDIR /spring-petclinic-rest

RUN mvn package

ENV SPRING_PROFILES_ACTIVE="mysql,spring-data-jpa" \
    SERVER_PORT="8081"

ENTRYPOINT \
    SPRING_DATASOURCE_URL="jdbc:mysql:replication://${DB_MASTER_ADDRESS}:${DB_MASTER_PORT},${DB_SLAVE_ADDRESS}:${DB_SLAVE_PORT}/petclinic?useUnicode=true&allowSourceDownConnections=true" \
    mvn spring-boot:run

