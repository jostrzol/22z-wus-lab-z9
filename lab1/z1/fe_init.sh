#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 MY_PORT BE_ADDRESS BE_PORT" >&2
    exit 1
fi

BE_ADDRESS="$2"

sudo apt update -y
sudo apt install -y git curl

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

cat > proxy.conf.json << EOL
{
    "/petclinic/api": {
        "target": "http://${BE_ADDRESS}:9966",
        "secure": false,
        "changeOrigin": true,
        "logLevel": "debug"
    }
}
EOL

ng serve --host 0.0.0.0 --proxy-config proxy.conf.json &
