#!/bin/sh

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 MY_PORT BE1_ADDRESS BE1_PORT BE2_ADDRESS BE2_PORT" >&2
    exit 1
fi

MY_PORT="$1"
BE1_ADDRESS="$2"
BE1_PORT="$3"
BE2_ADDRESS="$4"
BE2_PORT="$5"

sudo apt update -y
sudo apt install -y nginx

cat << EOF > /etc/nginx/sites-enabled/default
upstream backend {
  server $BE1_ADDRESS:$BE1_PORT;
  server $BE2_ADDRESS:$BE2_PORT;
}
server {
    listen $MY_PORT;
    location /petclinic/api {
      proxy_pass http://backend/petclinic/api;
      include proxy_params;
    }
}
EOF

sudo nginx -s reload
