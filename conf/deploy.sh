#!/bin/bash

set -e
source /etc/os-release

HOME_DIR=$(eval echo "~$SUDO_USER")

DO_RENDER=true
DO_BUILD=true
DO_NGINX=true
DO_SHINY=true

if [[ "$1" == "--skip" ]]; then
    shift
    for arg in "$@"; do
        [[ "$arg" == "render" ]] && DO_RENDER=false
        [[ "$arg" == "build" ]]  && DO_BUILD=false
        [[ "$arg" == "nginx" ]]  && DO_NGINX=false
        [[ "$arg" == "shiny" ]]  && DO_SHINY=false
    done
fi


if [[ "$DO_RENDER" == true ]]; then
    quarto render "$HOME_DIR/website"
fi

if [[ "$DO_BUILD" == true ]]; then
    Rscript "$HOME_DIR/website/conf/build.R"
fi

rm -rf /var/www/html/*
cp -r "$HOME_DIR/website/_site/." /var/www/html

rm -rf /var/www/autoindex
mkdir -p /var/www/autoindex
cp -r "$HOME_DIR/website/autoindex/." /var/www/autoindex

if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
    cp "$HOME_DIR/website/conf/nginx.conf" /etc/nginx/sites-available/default

elif [[ "$ID" == "fedora" ]]; then
    cp "$HOME_DIR/website/conf/nginx.conf" /etc/nginx/conf.d/default.conf

else
    echo "Distribuição não suportada: $ID"
    exit 1
fi

if [[ "$DO_NGINX" == true ]]; then
    systemctl restart nginx
fi

if [[ "$DO_SHINY" == true ]]; then
    pkill -f shiny-server || true
    shiny-server "$HOME_DIR/website/conf/shiny-server.conf"
fi

