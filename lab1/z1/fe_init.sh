#!/usr/bin/sh

apt update -y
apt install -y git curl sudo nginx

curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# npm uninstall -g angular-cli @angular/cli
# npm cache clean
npm install -g @angular/cli@11.2.11
git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
cd spring-petclinic-angular || exit
rm package-lock.json
npm config set legacy-peer-deps true
npm install --save-dev @angular/cli@11.2.11
npm install

echo N | ng analytics off

# TODO configure deployment config (e.g. nginx)
ng serve



# apt install nginx
# ng build --prod --base-href=/petclinic/ --deploy-url=/petclinic/
# mkdir -p /usr/share/nginx/html/petclinic
# cp -r dist/ /usr/share/nginx/html/petclinic

# tee -a /etc/nginx/nginx.conf << END

# server {
# 	listen       80 default_server;
#         root         /usr/share/nginx/html;
#         index index.html;

# 	location /petclinic/ {
#                 alias /usr/share/nginx/html/petclinic/dist/;
#                 try_files \$uri\$args \$uri\$args/ /petclinic/index.html;
#         }
# }

# END

