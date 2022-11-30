#!/bin/sh

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 MY_PORT WRITE_ADDRESS WRITE_PORT READ_ADDRESS READ_PORT" >&2
    exit 1
fi

MY_PORT="$1"
WRITE_ADDRESS="$2"
WRITE_PORT="$3"
READ_ADDRESS="$4"
READ_PORT="$5"

sudo apt update -y
sudo apt install -y nginx

cat << EOF > /etc/nginx/sites-enabled/lb
map \$request_method \$upstream_location {
   GET     $READ_ADDRESS:$READ_PORT;
   default $WRITE_ADDRESS:$WRITE_PORT;
}
server {
   listen $MY_PORT;
   location /petclinic/api/ {
      proxy_pass http://\$upstream_location;
      include proxy_params;
   }
}
EOF

sudo nginx -s reload
