FROM alpine:edge
LABEL maintainer="AkkarinD <carsten.vollmert@web.de>"

ENV TIME_ZONE "Europe/Berlin"
ENV CERT_FILE "cert.pem"
ENV PRIV_FILE "privkey.pem"
ENV CHAIN_FILE "chain.pem"

# Install packages
RUN	apk --update add --no-cache \
	openssl \
	curl \
	lighttpd \
	&& rm -rf /var/cache/apk/* \
	&& mkdir /run/lighttpd \
    && chown lighttpd:lighttpd /run/lighttpd

COPY	./config/lighttpd/ /config/lighttpd/
COPY	./start-lighttpd.sh /usr/local/bin/start-lighttpd.sh
COPY	./htdocs/* /var/www/localhost/htdocs/

RUN chmod 0755 /usr/local/bin/start-lighttpd.sh \
	&& rm -rf /etc/lighttpd \
	&& ln -s /config/lighttpd/ /etc/lighttpd \
	&& chown -R lighttpd:lighttpd /var/www/localhost
	
# Expose http(s) ports
EXPOSE 80 443

VOLUME 	["/usr/local/share/certdata","/config","/var/www/localhost/htdocs"]
CMD ["start-lighttpd.sh"]
