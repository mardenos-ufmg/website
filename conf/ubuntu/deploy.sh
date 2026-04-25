#!/bin/bash

set -e

HOME_DIR=$(eval echo "~$SUDO_USER")

quarto render "$HOME_DIR/website"

rm -rf /var/www/html/*
cp -r "$HOME_DIR/website/_site/." /var/www/html

rm -rf /var/www/autoindex
mkdir -p /var/www/autoindex
cp -r "$HOME_DIR/website/autoindex/." /var/www/autoindex

#cp "$HOME_DIR/website/conf/ubuntu/nginx.conf" /etc/nginx/sites-available/default
cp "$HOME_DIR/website/conf/nginx.conf" /etc/nginx/sites-available/default
systemctl restart nginx

pkill -f shiny-server || true
shiny-server "$HOME_DIR/website/conf/shiny-server.conf"
