#!/usr/bin/env bash

## Let's Encrypt post-renewal hook
# https://certbot.eff.org/docs/using.html?highlight=hook#renewing-certificates
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/https/letsencrypt-create-hooks.sh?$(date +%s) | sudo bash
#

echo ""
echo -e "\e[1;46m ============================= \e[0m"
echo -e "\e[1;46m 🪝 LET'S ENCRYPT CREATE HOOKS \e[0m"
echo -e "\e[1;46m ============================= \e[0m"

if [ -d "/etc/letsencrypt/renewal-hooks/deploy/" ]; then

  echo "🔃 Deploying Let's Encrypt post-renewal hook..."
  sudo curl -Lo /etc/letsencrypt/renewal-hooks/deploy/nginx_restart https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/nginx/restart.sh
  sudo chown root:root /etc/letsencrypt/renewal-hooks/deploy/nginx_restart
  sudo chmod u=rwx,go=rx /etc/letsencrypt/renewal-hooks/deploy/nginx_restart
  sudo certbot renew --force-renewal --no-random-sleep-on-renew
  
else

  echo "Let's Encrypt post-renewal hook skipped"
fi
