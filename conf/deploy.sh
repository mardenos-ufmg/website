#!/bin/bash

set -e
source /etc/os-release

HOME_DIR=$(eval echo "~$SUDO_USER")

if [ "$1" != "q" ]; then
    quarto render "$HOME_DIR/website"
fi

rm -rf /var/www/html/*
cp -r "$HOME_DIR/website/_site/." /var/www/html

rm -rf /var/www/autoindex
mkdir -p /var/www/autoindex
cp -r "$HOME_DIR/website/autoindex/." /var/www/autoindex


if [[ "$ID" == "ubuntu" ]]; then
    cp "$HOME_DIR/website/conf/nginx.conf" /etc/nginx/sites-available/default

elif [[ "$ID" == "fedora" ]]; then
    cp "$HOME_DIR/website/conf/nginx.conf" /etc/nginx/conf.d/default.conf

else
    echo "Distribuição não suportada: $ID"
    exit 1
fi

systemctl restart nginx


pkill -f shiny-server || true
shiny-server "$HOME_DIR/website/conf/shiny-server.conf"
