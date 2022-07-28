#!/usr/bin/env bash
### SET PHP VARIABLES SUCH AS PHP_VER AND PHP_CLI BY WEBSTACK.UP
#
# PHP_VER = '8.2'
# PHP_CLI = 'XDEBUG_MODE=off /bin/php8.2'
# PHP_FPM = 'php8.2-fpm'

# COMPOSER_EXE    = '${PHP_CLI} /usr/local/bin/composer --no-interaction'
# SYMFONY_EXE     = '${PHP_CLI} /usr/local/bin/symfony'
# N98_MAGERUN_EXE = '${PHP_CLI} /usr/local/bin/n98-magerun2'
# WP_CLI_EXE      = '${PHP_CLI} /usr/local/bin/wp-cli'

if [ -r "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh" ]; then
  source "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
  PHP_VER_FROM_GLOBAL=${PHP_VER}
fi


if [ ! -z "${PROJECT_DIR}" ] && [ -f "${PROJECT_DIR}.php-version" ]; then
  PHP_VER="$(head -n 1 "${PROJECT_DIR}.php-version")"
  PHP_VER_FROM_PROJECT=${PHP_VER}
fi


PHP_CLI="XDEBUG_MODE=off /bin/php${PHP_VER}"
PHP_FPM="php${PHP_VER}-fpm"
  
COMPOSER_EXE="${PHP_CLI} /usr/local/bin/composer --no-interaction"
SYMFONY_EXE="${PHP_CLI} /usr/local/bin/symfony"
MAGE_CLI_EXE="${PHP_CLI} bin/magento"
N98_MAGERUN_EXE="${PHP_CLI} /usr/local/bin/n98-magerun2"
WP_CLI_EXE="${PHP_CLI} /usr/local/bin/wp-cli"


showPHPVer()
{
  fxTitle "PHP version..."
  if [ -z "${PHP_VER}" ]; then
    fxWarning "No PHP_VER has been set"
  else
    echo "PHP_VER from global:   ${PHP_VER_FROM_GLOBAL}"
    echo "PHP_VER from project:  ${PHP_VER_FROM_PROJECT}"
    fxMessage "PHP_VER set to:        ${PHP_VER}"
  fi
}


function wsuMage()
{
  fxTitle "🧙 Running Magento bin/console..."

  if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
    fxCatastrophicError "MAGENTO_DIR not set"
  fi
  
  if [ -z "${EXPECTED_USER}" ]; then
    fxCatastrophicError "EXPECTED_USER not set"
  fi
  
  sudo rm -rf "/tmp/magento"
  
  local CURR_DIR_BACKUP=$(pwd)

  cd "${MAGENTO_DIR}"
  sudo -u "${EXPECTED_USER}" -H ${MAGE_CLI_EXE} $@
  
  cd "${CURR_DIR_BACKUP}"
}
