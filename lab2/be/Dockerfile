# REQUIRED ENVIRONMENT VARIABLES:
# * DB_ADDRESS
# * DB_PORT

# WILL RUN ON PORT 8080

FROM maven:3.8.6-eclipse-temurin-11-alpine as build-env

RUN apk add git
RUN git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
WORKDIR /spring-petclinic-rest

RUN mvn package

ENV SPRING_PROFILES_ACTIVE="mysql,spring-data-jpa" \
    SERVER_PORT="8080"

ENTRYPOINT \
    SPRING_DATASOURCE_URL="jdbc:mysql://${DB_ADDRESS}:${DB_PORT}/petclinic?useUnicode=true" \
    mvn spring-boot:run
