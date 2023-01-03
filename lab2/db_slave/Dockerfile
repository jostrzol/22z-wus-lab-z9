# WILL RUN ON PORT 3306

FROM mysql:8.0.31 as build-env

ARG DB_MASTER_ADDRESS
ARG DB_MASTER_PORT

COPY config-file.cnf /etc/mysql/conf.d/config-file.cnf

RUN echo "CHANGE MASTER TO MASTER_HOST='$DB_MASTER_ADDRESS', MASTER_USER='replikacja', MASTER_PORT=$DB_MASTER_PORT; start slave;" > /docker-entrypoint-initdb.d/1.sql

ENV MYSQL_ROOT_PASSWORD="root"
