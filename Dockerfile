FROM alpine:3.12
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
	&& rm -rf /var/cache/apk/*

COPY	./config/lighttpd/ /etc/lighttpd/
COPY	./start-lighttpd.sh /usr/local/bin/start-lighttpd.sh
COPY	./htdocs/* /var/www/localhost/htdocs/

RUN chmod 0755 /usr/local/bin/start-lighttpd.sh \
	&& chown -R lighttpd:lighttpd /var/www/localhost

# Expose http(s) ports
EXPOSE 80 443

# Define container health check; check every minute and wait 1 sec for http response
HEALTHCHECK --interval=1m --timeout=1s \
    CMD curl -f http://localhost/ || exit 1

VOLUME 	["/usr/local/share/certdata","/etc/lighttpd","/var/www/localhost/htdocs"]
CMD ["start-lighttpd.sh"]
