#!/bin/bash
echo ""

## Script name
SCRIPT_NAME=self-sign-generate

## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo " Generate self-signed, bogus certificate WEBSTACK.UP - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

SSL_DIR=/usr/local/turbolab.it/webstackup/autogenerated/

## New website data from CLI (if any)
SELFSIGN_DOMAIN=$1

while [ -z "$SELFSIGN_DOMAIN" ]
do
	echo ""
	read -p "Please provide the website domain (no-www! E.g.: turbolab.it) for this certificate: " SELFSIGN_DOMAIN  < /dev/tty
	
	if [ -z "${SELFSIGN_DOMAIN}" ]; then
	
		continue
	fi
	
	echo ""
	echo "Domain: $SELFSIGN_DOMAIN"
	
	SELFSIGN_DOMAIN_2ND=$(echo "$SELFSIGN_DOMAIN" |  cut -d '.' -f 1)
	SELFSIGN_DOMAIN_TLD=$(echo "$SELFSIGN_DOMAIN" |  cut -d '.' -f 2)
	
	if [ -z "${SELFSIGN_DOMAIN_2ND}" ] || [ -z "${SELFSIGN_DOMAIN_TLD}" ] || [ "${SELFSIGN_DOMAIN_2ND}" == "${SELFSIGN_DOMAIN_TLD}" ]; then
	
		SELFSIGN_DOMAIN=		
		echo "Invalid domain! Try again"
		continue
	fi
	
	echo ""
	echo "OK, this website domain looks valid!"

done


## https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=898470
#touch "$HOME/.rnd"

echo "Copy the configuration template..."
SELFSIGN_CONFIG=${SSL_DIR}https-self-sign-${SELFSIGN_DOMAIN}.conf
cp "/usr/local/turbolab.it/webstackup/config/https/self-sign-template.conf" "$SELFSIGN_CONFIG"
sed -i "s/localhost/${SELFSIGN_DOMAIN}/g" "$SELFSIGN_CONFIG"


echo ""
SELFSIGN_KEY=${SSL_DIR}openssl-private-key.pem
if [ ! -f "${SELFSIGN_KEY}" ]; then

	echo "Generating the private key..."
	openssl genrsa -out "${SELFSIGN_KEY}" 1024
else
	echo "Private key found"
fi


echo "Generating the certificate..."
openssl req -x509 -out ${SSL_DIR}https-${SELFSIGN_DOMAIN}.crt -key ${SELFSIGN_KEY} \
	-days 3650 \
	-nodes -sha256 \
	-subj "/CN=${SELFSIGN_DOMAIN}" \
	-extensions EXT -config "$SELFSIGN_CONFIG"


rm -f "$SELFSIGN_CONFIG"
		

echo "Trusting my new cert (Firfox only)..."
apt install libnss3-tools -y
killall firefox
for FIREFOX_DIR in /home/$(logname)/.mozilla/firefox/*; do

	if ls ${FIREFOX_DIR}/places.sqlite &>/dev/null; then
	
		echo "Found! $FIREFOX_DIR"
		certutil -D -n "${SELFSIGN_DOMAIN}"  -d sql:"${FIREFOX_DIR}" 
		certutil -A -n "${SELFSIGN_DOMAIN}" -t "TC,," -i ${SSL_DIR}https-${SELFSIGN_DOMAIN}.crt -d sql:"${FIREFOX_DIR}"
		certutil -d sql:"${FIREFOX_DIR}" -L
	fi
done


##
printMessage "Bogus HTTPS certificate ready"
