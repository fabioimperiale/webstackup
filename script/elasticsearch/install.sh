#!/usr/bin/env bash
### AUTOMATIC ELASTICSEARCH INSTALL BY WEBSTACK.UP

echo ""
echo -e "\e[1;46m ===================== \e[0m"
echo -e "\e[1;46m ELASTICSEARCH INSTALL \e[0m"
echo -e "\e[1;46m ===================== \e[0m"

if ! [ $(id -u) = 0 ]; then
  echo -e "\e[1;41m This script must run as ROOT \e[0m"
  exit
fi

echo ""
echo -e "\e[1;45m Removing previous version (if any) \e[0m"
apt purge --auto-remove elasticsearch* -y -qq

echo ""
echo -e "\e[1;45m Setting up the repo... \e[0m"
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
ES_APT_SOURCE_FILE=/etc/apt/sources.list.d/elastic-7.x.list
rm -f ${ES_APT_SOURCE_FILE}
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a ${ES_APT_SOURCE_FILE}

echo ""
echo -e "\e[1;45m Installing... \e[0m"
apt update -qq
apt install elasticsearch -y -qq

echo ""
echo -e "\e[1;45m Linking a base config... \e[0m"
if [ ! -f "/etc/elasticsearch/jvm.options.d/jvm.options" ]; then
  ln -s "${WEBSTACKUP_CONFIG_DIR}elasticsearch/jvm.options" "/etc/elasticsearch/jvm.options.d/"
else
  printMessage "Skipping! Config file already exists!"
fi

echo ""
echo -e "\e[1;45m Service management... \e[0m"
systemctl enable elasticsearch
service elasticsearch restart
systemctl --no-pager status elasticsearch

echo ""
echo -e "\e[1;45m Testing... \e[0m"
curl -X GET 'http://localhost:9200'

echo ""
echo -e "\e[1;45m Netstat... \e[0m"
ss -lpt | grep -i 'java\|elastic'
