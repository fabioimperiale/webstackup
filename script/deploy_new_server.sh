#!/bin/bash

source "$(dirname "$(readlink -f "$0")")/base.sh"

fxHeader "📚 DEPLOY NEW SERVER"
rootCheck

fxTitle "Loading default config..."
source ${WEBSTACKUP_INSTALL_DIR}webstackup.default.conf

## Default config error!
if [[ $WEBSTACKUP_ENABLED != 1 ]]; then
  catastrophicError "Default config file not available or script disabled"
fi


## Config file from CLI
CONFIGFILE_FULLPATH=$1
if [ ! -z "$CONFIGFILE_FULLPATH" ] && [ ! -f "$CONFIGFILE_FULLPATH" ]; then

  catastrophicError "Config file not found!
Please check if the following file exists and is accessible:
  
$CONFIGFILE_FULLPATH"

fi


## Config file from CLI OK
if [ ! -z "$CONFIGFILE_FULLPATH" ]; then
  
  fxTitle "Importing custom options"
  source "$CONFIGFILE_FULLPATH"
  
  fxMessage "Custom options imported from $CONFIGFILE_FULLPATH"
  
else

  CONFIGFILE_NAME=webstackup.conf
  CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME

  for CONFIGFILE_FULLPATH in "$CONFIGFILE_FULLPATH_ETC"
  do
    if [ -f "$CONFIGFILE_FULLPATH" ]; then
      source "$CONFIGFILE_FULLPATH"
    fi
  done
fi


fxTitle "Installing WEBSTACK.UP..."
if [ "$INSTALL_WEBSTACKUP" = 1 ]; then

  fxMessage "Installing dependencies..."
  apt update -qq
  apt install git software-properties-common gnupg2 dialog htop screen openssl zip unzip rsyslog -y -qq
  
  wsuMkAutogenDir
  >"${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
  
  fxMessage "Creating a new user account (the deployer)..."
  id -u webstackup &>/dev/null || useradd -G www-data webstackup --shell=/bin/false --create-home
  fxMessage $(cat /etc/passwd | grep webstackup)
  
  fxMessage "Generating an SSH key..."
  DEPLOYER_SSH_DIR=/home/webstackup/.ssh/
  mkdir -p "${DEPLOYER_SSH_DIR}"
  ssh-keyscan -t rsa github.com > "${DEPLOYER_SSH_DIR}known_hosts"
  touch "${DEPLOYER_SSH_DIR}config"
  chown webstackup:webstackup "${DEPLOYER_SSH_DIR}" -R
  
  chmod u=rwX,go= "${DEPLOYER_SSH_DIR}" -R
  sudo -u webstackup -H ssh-keygen -t rsa -f "${DEPLOYER_SSH_DIR}id_rsa" -N ''
  
  chmod u=rX,go= "${DEPLOYER_SSH_DIR}" -R
  chmod u=rw,go= "${DEPLOYER_SSH_DIR}known_hosts"
  
  sudo -u webstackup -H git config --global user.name "webstack.up"
  sudo -u webstackup -H git config --global user.email "info@webstack.up"
  
  fxMessage "Keep SSH alive..."
  cp "${WEBSTACKUP_INSTALL_DIR}config/ssh/keepalive.conf" /etc/ssh/sshd_config.d/
  
  fxMessage "Updating MOTD"
  source "${WEBSTACKUP_SCRIPT_DIR}motd/setup.sh"

else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Changing hostname..."
if [ ! -z "$INSTALL_HOSTNAME" ]; then

  fxTitle "Setting hostname to ${INSTALL_HOSTNAME}..."
  hostnamectl set-hostname ${INSTALL_HOSTNAME}
  hostnamectl set-hostname ${INSTALL_HOSTNAME} --static
  echo "127.0.0.1   ${INSTALL_HOSTNAME}" >> /etc/hosts
  
else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing cron..."
if [ "$INSTALL_CRON" = 1 ]; then

  apt install cron -y -qq
  
  fxTitle "Deploying webstackup cron file..."
  cp "${WEBSTACKUP_INSTALL_DIR}config/cron/webstackup" /etc/cron.d/
fi


fxTitle "Set the timezone..."
if [ ! -z "$INSTALL_TIMEZONE" ]; then 

  timedatectl set-timezone $INSTALL_TIMEZONE
  service syslog restart
  service cron restart
fi


fxTitle "Installing NGINX..."
if [ "$INSTALL_NGINX" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}nginx/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing PHP..."
if [ "$INSTALL_PHP" = 1 ]; then
  bash PHP_VER=${PHP_VER} ${WEBSTACKUP_SCRIPT_DIR}php/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing MYSQL..."
if [ "$INSTALL_MYSQL" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}mysql/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ELASTICSEARCH..."
if [ "$INSTALL_ELASTICSEARCH" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}elasticsearch/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing PURE-FTPD..."
if [ "$INSTALL_PUREFTPD" = 1 ]; then
  
  fxMessage "Removing previous version (if any)"
  apt purge --auto-remove pure-ftpd* -y -qq
  source ${WEBSTACKUP_SCRIPT_DIR}pure-ftpd/install.sh
  
else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing COMPOSER..."
if [ "$INSTALL_COMPOSER" = 1 ]; then

  fxMessage "Downloading..."
  COMPOSER_EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  COMPOSER_ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
  
  if [ "$COMPOSER_EXPECTED_SIGNATURE" != "$COMPOSER_ACTUAL_SIGNATURE" ]; then
  
    catastrophicError "Composer signature doesn't match! Abort! Abort!"

Expec. hash: ### ${COMPOSER_EXPECTED_SIGNATURE}
Actual hash: ### ${COMPOSER_ACTUAL_SIGNATURE}"
  fi
  
  fxMessage "Installing..."
  php composer-setup.php --filename=composer --install-dir=/usr/local/bin
  php -r "unlink('composer-setup.php');"
  
else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing SYMFONY"
if [ "$INSTALL_SYMFONY" = 1 ]; then
  
  fxMessage "Installing..."
  wget https://get.symfony.com/cli/installer -O - | bash
  mv /root/.symfony5/bin/symfony /usr/local/bin/symfony
  rm -rf "/root/.symfony5"
  
  fxMessage "$(symfony -V)"
  
else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ZZUPDATE..."
if [ "$INSTALL_ZZUPDATE" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzupdate/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ZZMYSQLDUMP"
if [ "$INSTALL_ZZMYSQLDUMP" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzmysqldump/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing XDEBUG..."
if [ "$INSTALL_XDEBUG" = 1 ]; then

  fxMessage "Installing..."
  apt install php-xdebug -y -qq
  
  fxMessage "Activating custom xdebug config..."
  XDEBUG_CONFIG_FILE_FULLPATH="${WEBSTACKUP_INSTALL_DIR}config/php/xdebug.ini"  
  ln -s "$XDEBUG_CONFIG_FILE_FULLPATH" /etc/php/${PHP_VER}/fpm/conf.d/30-webstackup-xdebug.ini
  ln -s "$XDEBUG_CONFIG_FILE_FULLPATH" /etc/php/${PHP_VER}/cli/conf.d/30-webstackup-xdebug.ini
  
  service php${PHP_VER}-fpm restart

else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing LET'S ENCRYPT..."
if [ $INSTALL_LETSENCRYPT = 1 ]; then
  
  fxMessage "Installing..."
  apt install certbot -y -qq
  fxMessage "$(certbot --version)"
  service cron restart
  source "${WEBSTACKUP_SCRIPT_DIR}https/letsencrypt-create-hooks.sh"
  
else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing POSTFIX and OPENDKIM"
if [ "$INSTALL_POSTFIX" = 1 ]; then

  fxMessage "Installing..."
  apt install postfix mailutils opendkim opendkim-tools -y -qq
  
  fxMessage "Adding the postfix user to the opendkim group..."
  adduser postfix opendkim
  
  fxMessage "Wiring together opendkim and postfix..."
  mkdir /var/spool/postfix/opendkim
  chown opendkim:postfix /var/spool/postfix/opendkim
  
  sed -i -e 's|^UMask|#UMask|g' /etc/opendkim.conf
  sed -i -e 's|^Socket|#Socket|g' /etc/opendkim.conf
  echo "" >>  /etc/opendkim.conf
  echo "" >>  /etc/opendkim.conf
  echo "" >>  /etc/opendkim.conf
  cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/opendkim_to_be_appended.conf" >> /etc/opendkim.conf
  
  echo "" >>  /etc/postfix/main.cf
  echo "" >>  /etc/postfix/main.cf
  echo "" >>  /etc/postfix/main.cf
  cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/postfix_to_be_appended.conf" >> /etc/postfix/main.cf
  
  sed -i -e 's|^SOCKET=|#SOCKET=|g' /etc/default/opendkim
  echo "" >> /etc/default/opendkim
  echo "" >> /etc/default/opendkim
  echo "" >> /etc/default/opendkim
  cat "${WEBSTACKUP_INSTALL_DIR}config/opendkim/opendkim-default_to_be_appended.conf" >> /etc/default/opendkim
  
  mkdir -p /etc/opendkim/keys
  
  cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/TrustedHosts" /etc/opendkim/TrustedHosts
  cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/KeyTable" /etc/opendkim/KeyTable
  cp "${WEBSTACKUP_INSTALL_DIR}config/opendkim/SigningTable" /etc/opendkim/SigningTable
  
  chown opendkim:opendkim /etc/opendkim/ -R
  chmod ug=rwX,o=rX /etc/opendkim/ -R
  chmod u=rwX,og=X /etc/opendkim/keys -R
  
  service postfix restart
  service opendkim restart
  
else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing ZZALIAS..."
if [ "$INSTALL_ZZALIAS" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzalias/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Firewalling..."
if [ "$INSTALL_FIREWALL" = 1 ]; then
  curl -s https://raw.githubusercontent.com/TurboLabIt/zzfirewall/master/setup.sh | sudo bash
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Creating users..."
if [ ! -z "$INSTALL_USERS_TEMPLATE_PATH" ]; then
  bash "${WEBSTACKUP_SCRIPT_DIR}account/create_and_copy_template.sh" "$INSTALL_USERS_TEMPLATE_PATH"
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Disable SSH password login..."
if [ "$INSTALL_SSH_DISABLE_PASSWORD_LOGIN" = 1 ]; then

  ln -s "${WEBSTACKUP_INSTALL_DIR}config/ssh/disable-password-login.conf" /etc/ssh/sshd_config.d/
  service sshd restart
  
else
  
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing CHROME..."
if [ "$INSTALL_CHROME" = 1 ]; then
  source ${WEBSTACKUP_SCRIPT_DIR}chrome/install.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Running cloning wizard..."
if [ "$INSTALL_GIT_CLONE_WEBAPP" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}filesystem/git-clone-a-webapp.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Installing and running benchmark..."
if [ "$INSTALL_BENCHMARK" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}performance/benchmark.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "Running Poweroff disabler..."
if [ "$INSTALL_DISABLE_POWEROFF" = 1 ]; then
  bash ${WEBSTACKUP_SCRIPT_DIR}system/poweroff-disabler.sh
else
  fxInfo "Skipped (disabled in config)"
fi


fxTitle "REBOOTING..."
if [ "$REBOOT" = "1" ] && [ "$INSTALL_ZZUPDATE" = 1 ]; then

  fxCountdown
  zzupdate

elif [ "$REBOOT" = "1" ]; then

  fxCountdown
  shutdown -r -t 5

else
  
  fxInfo "Skipped (disabled in config)"
fi


fxEndFooter
