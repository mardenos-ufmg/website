#!/bin/bash

set -e

HOME_DIR=$(eval echo "~$SUDO_USER")

quarto render "$HOME_DIR/website"

rm -rf /usr/share/nginx/html/*
cp -r "$HOME_DIR/website/_site/." /usr/share/nginx/html

rm -rf /usr/share/nginx/html/autoindex
mkdir -p /usr/share/nginx/html/autoindex
cp -r "$HOME_DIR/website/autoindex/." /usr/share/nginx/html/autoindex

cp "$HOME_DIR/website/conf/ubuntu/nginx.conf" /etc/nginx/default.d/nginx.conf
systemctl restart nginx

sudo pkill -f shiny-server || true
shiny-server "$HOME_DIR/website/conf/shiny-server.conf"
