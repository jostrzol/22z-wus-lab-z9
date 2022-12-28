FROM node:12.11.1 as build-env

RUN git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
WORKDIR /spring-petclinic-angular

RUN echo N | npm install -g @angular/cli@11.2.11 && \
    echo N | npm install && \
    echo N | ng analytics off

RUN sed -i "s#http://localhost:9966##g" src/environments/environment.ts && \
    sed -i "s#http://localhost:9966##g" src/environments/environment.prod.ts

RUN ng build --prod --base-href=/petclinic/ --deploy-url=/petclinic/

FROM nginx
COPY --from=build-env /spring-petclinic-angular/dist /usr/share/nginx/html/petclinic
COPY nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT envsubst '$BE_ADDRESS $BE_PORT' \
    < /etc/nginx/conf.d/default.conf \
    > /tmpdefault && mv /tmpdefault /etc/nginx/conf.d/default.conf && \
    cat /etc/nginx/conf.d/default.conf && \
    nginx -g 'daemon off;'
