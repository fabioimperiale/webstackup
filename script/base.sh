#!/bin/bash

## kill the whole script on Ctrl+C
trap "exit" INT

##
if [ -z "$TIME_START" ]; then
  TIME_START="$(date +%s)"
fi

#### Webstackup directory
WEBSTACKUP_INSTALL_DIR_PARENT=/usr/local/turbolab.it/
WEBSTACKUP_INSTALL_DIR=${WEBSTACKUP_INSTALL_DIR_PARENT}webstackup/
WEBSTACKUP_AUTOGENERATED_DIR=${WEBSTACKUP_INSTALL_DIR}autogenerated/
WEBSTACKUP_CONFIG_DIR=${WEBSTACKUP_INSTALL_DIR}config/
WEBSTACKUP_SCRIPT_DIR=${WEBSTACKUP_INSTALL_DIR}script/

#### Calling script paths (it works only when it's called as `source base.sh`)
## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

##
INITIAL_DIR=$(pwd)
PROJECT_DIR=$(readlink -m "${SCRIPT_DIR}..")/
WEBROOT_DIR=${PROJECT_DIR}public/

##
source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
source "${WEBSTACKUP_SCRIPT_DIR}php/commands.sh"
source "${WEBSTACKUP_SCRIPT_DIR}mysql/commands.sh"
source "${WEBSTACKUP_SCRIPT_DIR}deprecated-retrocompat.sh"

## Hostname
HOSTNAME="$(hostname)"

INSTALLED_RAM=$(awk '/MemFree/ { printf "%.3f \n", $2/1024/1024 }' /proc/meminfo)
INSTALLED_RAM="${INSTALLED_RAM//.}"
