#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 MY_PORT BE_ADDRESS BE_PORT" >&2
    exit 1
fi

MY_PORT="$1"
BE_ADDRESS="$2"
BE_PORT="$3"

sudo apt update -y
sudo apt install -y git curl nginx

# Install nvm node manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install 12.11.1

git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
cd spring-petclinic-angular || exit

echo N | npm install -g @angular/cli@11.2.11
echo N | npm install
echo N | ng analytics off

sed -i "s#http://localhost:9966##g" src/environments/environment.ts
sed -i "s#http://localhost:9966##g" src/environments/environment.prod.ts

ng build --prod --base-href=/petclinic/ --deploy-url=/petclinic/

sudo mkdir /usr/share/nginx/html/petclinic 
sudo cp -r dist/ /usr/share/nginx/html/petclinic

cat > default << EOL
server {
	listen       $MY_PORT default_server;
    root         /usr/share/nginx/html;
    index /petclinic/index.html;

	location /petclinic/ {
        alias /usr/share/nginx/html/petclinic/dist/;
        try_files \$uri\$args \$uri\$args/ /petclinic/index.html;
    }

    location /petclinic/api/ {
        proxy_pass http://${BE_ADDRESS}:$BE_PORT;
        include proxy_params;
    }
}
EOL
sudo mv default /etc/nginx/sites-enabled/default

sudo nginx -s reload
