#!/bin/sh

#SET THE TIMEZONE
apk add --update tzdata
cp /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
echo $TIME_ZONE > /etc/timezone
apk del tzdata

# Handle provided certificate files or create self signed certificate
mkdir -p /etc/lighttpd/ssl/
if [ -f /usr/local/share/certdata/$CERT_FILE ] && [ -f /usr/local/share/certdata/$PRIV_FILE ]
	then
		cat /usr/local/share/certdata/$CERT_FILE /usr/local/share/certdata/$PRIV_FILE > /etc/lighttpd/ssl/localhost.pem 
		cp /usr/local/share/certdata/$CERT_FILE /etc/lighttpd/ssl/$CERT_FILE
		cp /usr/local/share/certdata/$PRIV_FILE /etc/lighttpd/ssl/$PRIV_FILE
		cp /usr/local/share/certdata/$CHAIN_FILE /etc/lighttpd/ssl/$CHAIN_FILE
		chmod 400 /etc/lighttpd/ssl/*.pem
elif [ ! -f /etc/lighttpd/ssl/localhost.pem ]
	then
		openssl req -x509 -newkey rsa:4096 -keyout /tmp/key.pem -out /tmp/cert.pem -days 365 -subj '/CN=localhost' -nodes -sha256
		cat /tmp/key.pem /tmp/cert.pem > /etc/lighttpd/ssl/localhost.pem
		rm /tmp/key.pem /tmp/cert.pem
		chmod 400 /etc/lighttpd/ssl/localhost.pem
fi

#PREPARE THE PERMISSIONS FOR VOLUMES
mkdir -p /config
chown -R root:root /config
chmod -R 755 /config

#LAUNCH THE INIT PROCESS
tail -F /var/log/lighttpd/access.log 2>/dev/null &
tail -F /var/log/lighttpd/error.log 2>/dev/null 1>&2 &
lighttpd -D -f /etc/lighttpd/lighttpd.conf

