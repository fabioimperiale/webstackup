#!/usr/bin/env bash
### AUTOMATIC APACHE HTTP SERVER INSTALLER BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/apache-httpd/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/apache-httpd/install.sh?$(date +%s) | sudo bash
#
# Based on: https://turbolab.it/1379

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Apache HTTP Server installer"
rootCheck

fxTitle "Removing any old previous instance..."
apt purge --auto-remove apache2* -y 
rm -rf /etc/apache2

## installing/updating WSU
WSU_DIR=/usr/local/turbolab.it/webstackup/
if [ ! -f "${WSU_DIR}setup.sh" ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/setup.sh?$(date +%s) | sudo bash
fi

source "${WSU_DIR}script/base.sh"

fxTitle "Installing prerequisites..."
apt update -qq
apt install curl gnupg2 ca-certificates lsb-release -y

fxTitle "Installing additional utilities..."
apt install software-properties-common openssl zip unzip nano -y

bash ${WEBSTACKUP_SCRIPT_DIR}account/generate-www-data.sh

wsuMkAutogenDir

fxTitle "Generating dhparam..."
openssl dhparam -out "${WEBSTACKUP_AUTOGENERATED_DIR}dhparam.pem" 2048 > /dev/null 2>&1 &

bash ${WEBSTACKUP_SCRIPT_DIR}account/generate-http-basic-auth.sh


fxTitle "apt install apache..."
apt update -qq
apt install apache2 libapache2-mod-fcgid -y


fxTitle "Disable Prefork and Worker MPMs..."
a2dismod mpm_prefork mpm_worker

fxTitle "Enable Apache Event module..."
a2enmod mpm_event

fxTitle "Enable HTTP/2 support...."
a2enmod http2

fxTitle "Enable mod_rewrite...."
a2enmod rewrite

fxTitle "Enable mod_ssl..."
a2enmod ssl


fxTitle "Disable and remove mod_php (if any)..."
a2dismod php* -f
apt purge libapache2-mod-php* -y

fxTitle "Enable Apache FastCGI module (for PHP)..."
a2enmod proxy_fcgi setenvif

fxTitle "Enabling ${PHP_FPM} support..."
## enabling PHP globally is not desirable, b/c it forces the same version for every vhost
if [ ! -z "${APACHE_PHP_GLOBAL_ENABLE}" ] && [ ! -z "${PHP_VER}" ] && [ ! -z "${PHP_FPM}" ]; then
  a2enconf ${PHP_FPM}
else
  fxInfo "Function disabled or PHP not found, skipping"  
fi

## Create a self-signed, bogus certificate
bash "${WEBSTACKUP_SCRIPT_DIR}https/self-sign-generate.sh" localhost

fxTitle "Disable HTTP: upgrade all connections to HTTPS..."
fxLink "${WEBSTACKUP_CONFIG_DIR}apache-httpd/global_https_upgrade_all.conf" /etc/apache2/sites-available/00_global_https_upgrade_all.conf
a2ensite 00_global_https_upgrade_all

fxTitle "Disable the default Apache vhost configuration..."
a2dissite 000-default

fxTitle "Return 400 to requests for undefined websites..."
fxLink "${WEBSTACKUP_CONFIG_DIR}apache-httpd/global_default_vhost_disable.conf" /etc/apache2/sites-available/05_global_default_vhost_disable.conf
a2ensite 05_global_default_vhost_disable

## ... TO BE CONTINUED ...

fxTitle "Final restart..."
apachectl configtest
service apache2 restart

fxEndFooter
