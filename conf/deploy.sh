#!/bin/bash

set -e

HOME_DIR=$(eval echo "~$SUDO_USER")

quarto render "$HOME_DIR/website"
rm -rf /var/www/html/*
cp -r "$HOME_DIR/website/_site/." /var/www/html

sudo pkill -f shiny-server || true
shiny-server "$HOME_DIR/website/conf/shiny-server.conf"
