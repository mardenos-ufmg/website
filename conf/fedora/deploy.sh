#!/bin/bash

set -e

HOME_DIR=$(eval echo "~$SUDO_USER")

quarto render "$HOME_DIR/website"

rm -rf /usr/share/nginx/html/*
cp -r "$HOME_DIR/website/_site/." /var/www/html
#cp -r "$HOME_DIR/website/_site/." /usr/share/nginx/html

rm -rf /usr/share/nginx/html/autoindex
mkdir -p /usr/share/nginx/html/autoindex
#cp -r "$HOME_DIR/website/autoindex/." /usr/share/nginx/html/autoindex
cp -r "$HOME_DIR/website/autoindex/." /var/www

#cp "$HOME_DIR/website/conf/fedora/nginx.conf" /etc/nginx/conf.d/default.conf
cp "$HOME_DIR/website/conf/nginx.conf" /etc/nginx/conf.d/default.conf
systemctl restart nginx

pkill -f shiny-server || true
shiny-server "$HOME_DIR/website/conf/shiny-server.conf"
