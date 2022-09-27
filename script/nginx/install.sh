

#!/usr/bin/env bash
### AUTOMATIC NGINX INSTALL BY WEBSTACK.UP
# https://github.com/TurboLabIt/webstackup/tree/master/script/nginx/install.sh
#
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/nginx/install.sh?$(date +%s) | sudo bash
#
# Based on: https://turbolab.it/1482 | http://nginx.org/en/linux_packages.html#Ubuntu

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "💿 Nginx installer "
rootCheck

fxTitle "Removing any old previous instance..."
apt purge --auto-remove nginx* -y

fxTitle "Installing Nginx prerequisites from docs..."
apt update -qq
apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring -y

fxTitle "Installing additional utilities..."
apt install unzip nano -y

fxTitle "Import an official nginx signing key..."
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

fxTitle "Verify that the downloaded file contains the proper key..."
gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

fxTitle "Selecting mainline..."
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

fxTitle "Set up repository pinning to prefer our packages over distribution-provided ones..."
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx
  
fxTitle "Install Nginx..."
apt update -qq
apt install nginx -y

if [ -f "/usr/local/turbolab.it/webstackup/config/nginx/85_status_page.conf" ] && [ ! -f "/etc/nginx/conf.d/status_page.conf" ]; then

  fxTitle "Webstackup in installed! Linking status_page..."
  ln -s /usr/local/turbolab.it/webstackup/config/nginx/85_status_page.conf /etc/nginx/conf.d/status_page.conf

elif [ ! -f "/etc/nginx/conf.d/status_page.conf" ]; then
  
  fxTitle "Downloading status_page..."
  curl -o "/etc/nginx/conf.d/status_page.conf" https://raw.githubusercontent.com/TurboLabIt/webstackup/master/config/nginx/85_status_page.conf
fi


if [ ! -f "/usr/local/turbolab.it/webstackup/autogenerated/nginx-php_ver.conf" ]; then

  fxTitle "PHP_VER file not found. Setting up a dummy one...."
  mkdir -p "/usr/local/turbolab.it/webstackup/autogenerated/"
  echo "set \$PHP_VER 99.99;"  >> "/usr/local/turbolab.it/webstackup/autogenerated/nginx-php_ver.conf"
fi


fxTitle "Disable the default error_log. You MUST set your own at the server{} level!"
sed -i "s|error_log|#error_log|g" /etc/nginx/nginx.conf

fxTitle "Starting the service..."
service nginx restart
