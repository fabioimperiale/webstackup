#!/bin/bash

## Install directory
WEBSTACKUP_INSTALL_DIR_PARENT=/usr/local/turbolab.it/
WEBSTACKUP_INSTALL_DIR=${WEBSTACKUP_INSTALL_DIR_PARENT}webstackup/
WEBSTACKUP_AUTOGENERATED_DIR=${WEBSTACKUP_INSTALL_DIR}autogenerated/

## Absolute path to this script, e.g. /home/user/bin/foo.sh
WEBSTACKUP_SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
WEBSTACKUP_SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

if [ -z "$SCRIPT_FULLPATH" ]; then

	## Absolute path to this script, e.g. /home/user/bin/foo.sh
	SCRIPT_FULLPATH=$(readlink -f "$0")

	## Absolute path this script is in, thus /home/user/bin
	SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/
fi

if [ -z "$TIME_START" ]; then

	TIME_START="$(date +%s)"
fi

## Header (green)
WEBSTACKUP_FRAME="O===========================================================O"
printHeader ()
{

	STYLE='\033[42m'
	RESET='\033[0m'

	echo ""
	echo -n -e $STYLE
	echo ""
	echo "$WEBSTACKUP_FRAME"
	echo " --> $1 - $(date) on $(hostname)"
	echo "$WEBSTACKUP_FRAME"
	echo -e $RESET
}


function printTheEnd ()
{
	echo ""
	echo "The End"
	echo $(date)
	
	if [ ! -z "$TIME_START" ]; then
		echo "$((($(date +%s)-$TIME_START)/60)) min."
	fi
	
	echo "$WEBSTACKUP_FRAME"
	exit
}


function catastrophicError ()
{
	STYLE='\033[41m'
	RESET='\033[0m'

	echo ""
	echo -n -e $STYLE
	echo "vvvvvvvvvvvvvvvvvvvv"
	echo "Catastrophic error!!"
	echo "^^^^^^^^^^^^^^^^^^^^"
	echo "$1"
	echo -e $RESET
	
	printTheEnd
}


rootCheck ()
{
	if ! [ $(id -u) = 0 ]; then

		catastrophicError "This script must run as ROOT"
	fi
}


function printTitle ()
{
	STYLE='\033[44m'
	RESET='\033[0m'

    echo ""
	echo -n -e $STYLE
    echo "$1"
    printf '%0.s-' $(seq 1 ${#1})
	echo -e $RESET
	echo ""
}


function printMessage ()
{
	STYLE='\033[45m'
	RESET='\033[0m'

	echo ""
	echo -n -e $STYLE
    echo "$1"
	echo -e $RESET
	echo ""
}


printLightWarning ()
{
	STYLE='\033[33m'
	RESET='\033[0m'

	echo ""
	echo -n -e $STYLE
    echo "$1"
	echo -e $RESET
	echo ""
}


if [ -r "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh" ]; then

	source "${WEBSTACKUP_AUTOGENERATED_DIR}variables.sh"
fi


if [ -r "/etc/turbolab.it/mysql.conf" ]; then

	source "/etc/turbolab.it/mysql.conf"
fi
