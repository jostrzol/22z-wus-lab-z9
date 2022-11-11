#!/usr/bin/sh

if [ "$#" -ne 1 ] || ! [ -d "$1" ]; then
  echo "Usage: $0 BE URL" >&2
  exit 1
fi

BE_URL="$!"

apt update -y
apt install -y git curl

# Install n node manager
curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
bash n lts
npm install -g n
n 12.11.1

npm uninstall -g angular-cli @angular/cli
npm cache clean --force
echo N | npm install -g @angular/cli@11.2.11
git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
cd spring-petclinic-angular || exit
rm package-lock.json
npm config set legacy-peer-deps true
echo N | npm install --save-dev @angular/cli@11.2.11
npm install

echo N | ng analytics off

# TODO configure deployment config (e.g. nginx)

sed -i "s/localhost/${BE_URL}/g" src/environments/environment.ts
sed -i "s/localhost/${BE_URL}/g" src/environments/environment.prod.ts

ng serve --host 0.0.0.0



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

