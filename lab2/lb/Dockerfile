FROM nginx
WORKDIR /nginx
COPY nginx.conf petclinic.conf
ENTRYPOINT envsubst '$BE_WRITE_ADDRESS $BE_WRITE_PORT $BE_READ_ADDRESS $BE_READ_PORT' \
    < petclinic.conf  \
    > /etc/nginx/conf.d/petclinic.conf && \
    nginx -g 'daemon off;'