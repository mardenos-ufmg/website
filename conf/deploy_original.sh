#!/bin/bash

quarto render
rm -rf /var/www/html/*
cp -r ~/website/_site/. /var/www/html
shiny-server ~/website/conf/shiny-server.conf
