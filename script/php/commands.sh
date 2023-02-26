#!/usr/bin/env bash
### READY-TO-RUN, FULLY CUSTOMIZED PHP COMMANDS BY WEBSTACK.UP
#
# wsuMage cache:flush
# wsuComposer install
#
# COMPOSER_JSON_FULLPATH
# COMPOSER_SKIP_DUMP_AUTOLOAD

source $(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/version-variables.sh


## composer
function wsuComposer()
{
  fxTitle "📦 Running composer..."
  echo "composer $@"
  echo ""
  
  expectedUserSetCheck


  if [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${PROJECT_DIR}composer.json" ]; then

    COMPOSER_JSON_FULLPATH=${PROJECT_DIR}composer.json

  elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "${WEBROOT_DIR}composer.json" ]; then

    COMPOSER_JSON_FULLPATH=${WEBROOT_DIR}composer.json

  elif [ -z "${COMPOSER_JSON_FULLPATH}" ] && [ -f "composer.json" ]; then

    COMPOSER_JSON_FULLPATH=$(pwd)/composer.json
  fi


  if [ ! -z "${APP_ENV}" ] && [ "${APP_ENV}" != "dev" ] && [ "$1" = "install" ]; then
    local NO_DEV="--no-dev"
  fi
  
  
  if [ -z "${COMPOSER_JSON_FULLPATH}" ]; then
  
    fxInfo "composer.json not found"
    local FULL_COMPOSER_CMD="sudo -u $EXPECTED_USER -H XDEBUG_MODE=off COMPOSER_MEMORY_LIMIT=-1 ${PHP_CLI} /usr/local/bin/composer"
  
  else
  
    fxInfo "Using ##${COMPOSER_JSON_FULLPATH}##"
    local FULL_COMPOSER_CMD="sudo -u $EXPECTED_USER -H COMPOSER="$(basename -- $COMPOSER_JSON_FULLPATH)" XDEBUG_MODE=off COMPOSER_MEMORY_LIMIT=-1 ${PHP_CLI} /usr/local/bin/composer --working-dir "$(dirname ${COMPOSER_JSON_FULLPATH})""
  fi


  ${FULL_COMPOSER_CMD} "$@" --no-interaction ${NO_DEV}
}


## Magento bin/console
function wsuMage()
{
  expectedUserSetCheck

  if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
    fxCatastrophicError "📁 MAGENTO_DIR not set"
  fi

  sudo rm -rf "/tmp/magento"

  local CURR_DIR_BACKUP=$(pwd)

  cd "${MAGENTO_DIR}"
  sudo -u "${EXPECTED_USER}" -H XDEBUG_MODE=off ${PHP_CLI} bin/magento "$@"

  cd "${CURR_DIR_BACKUP}"
}


## Magento n98-magerun2
function wsuN98MageRun()
{
  expectedUserSetCheck

  if [ -z "${MAGENTO_DIR}" ] || [ ! -d "${MAGENTO_DIR}" ]; then
    fxCatastrophicError "📁 MAGENTO_DIR not set"
  fi

  sudo rm -rf "/tmp/magento"

  local CURR_DIR_BACKUP=$(pwd)

  cd "${MAGENTO_DIR}"
  sudo -u $EXPECTED_USER -H XDEBUG_MODE=off ${PHP_CLI} /usr/local/bin/n98-magerun2 "$@"

  cd "${CURR_DIR_BACKUP}"
}


## Symfony executable
function wsuSymfony()
{
  fxTitle "🎼 Running symfony..."
  expectedUserSetCheck

  if [ -z "${PROJECT_DIR}" ] || [ ! -d "${PROJECT_DIR}" ]; then
    fxCatastrophicError "📁 PROJECT_DIR not set"
  fi

  sudo rm -rf "/tmp/symfony"

  local SYMFONY_FILE_PATH=/usr/bin/symfony

  if [ ! -f "${SYMFONY_FILE_PATH}" ]; then
    bash "${WEBSTACKUP_SCRIPT_DIR}frameworks/symfony/install.sh"
  fi

  if [ -z $(command -v unbuffer) ]; then
  
    fxTitle "unbuffer is not installed. Installing it now..."
    sudo apt update
    sudo apt install expect -y
  fi

  local CURR_DIR_BACKUP=$(pwd)

  cd "${PROJECT_DIR}"
  
  fxInfo "$(pwd)"
  echo "symfony $@"
  echo ""
  
  sudo -u "${EXPECTED_USER}" -H XDEBUG_MODE=off unbuffer ${SYMFONY_FILE_PATH} "$@"

  cd "${CURR_DIR_BACKUP}"
}


## WordPress CLI
function wsuWordPress()
{
  fxTitle "📰 Running wp-cli..."
  expectedUserSetCheck

  if [ -z "${WEBROOT_DIR}" ] || [ ! -d "${WEBROOT_DIR}" ]; then
    fxCatastrophicError "📁 WEBROOT_DIR not set"
  fi
  
  local WPCLI_FILE_PATH=/usr/local/bin/wp-cli

  if [ ! -f "${WPCLI_FILE_PATH}" ]; then
    bash "${WEBSTACKUP_SCRIPT_DIR}frameworks/wordpress/install.sh"
  fi
  
  local CURR_DIR_BACKUP=$(pwd)

  cd "${WEBROOT_DIR}"
  
  fxInfo "$(pwd)"
  echo "wp-cli $@"
  echo ""
  
  sudo -u $EXPECTED_USER -H XDEBUG_MODE=off ${PHP_CLI} ${WPCLI_FILE_PATH} --path="${WEBROOT_DIR%*/}/" "$@"

  cd "${CURR_DIR_BACKUP}"
}


function wsuOpcacheClear()
{
  sudo service ${PHP_FPM} reload
  return 0

  ## cachetool https://github.com/gordalina/cachetool
  # The application requires the version ">=8.0.0" or greater
  local CACHETOOL_FILE_PATH=/usr/local/bin/cachetool

  if [ ! -f "${CACHETOOL_FILE_PATH}" ]; then
    fxTitle "cachetool is not installed. Installing..."
    sudo curl -Lo "${CACHETOOL_FILE_PATH}" https://github.com/gordalina/cachetool/releases/latest/download/cachetool.phar
    sudo chmod u=rwx,go=rx "${CACHETOOL_FILE_PATH}"
  fi

  local CACHETOOL_EXE="${PHP_CLI} ${CACHETOOL_FILE_PATH}"
  sudo ${CACHETOOL_EXE} opcache:reset --fcgi=/run/php/${PHP_FPM}.sock
}
