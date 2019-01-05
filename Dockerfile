FROM alpine:3.8
LABEL maintainer="AkkarinD <carsten.vollmert@web.de>"

ENV TIME_ZONE "Europe/Berlin"
ENV CERT_FILE "cert.pem"
ENV PRIV_FILE "privkey.pem"

# Install packages
RUN	apk update \
	&& apk add --no-cache \
	openssl \
#	curl \
	lighttpd \
	&& rm -rf /var/cache/apk/* \
	&& mkdir /run/lighttpd \
    && chown lighttpd:lighttpd /run/lighttpd

COPY	./config/lighttpd/ /config/lighttpd/
COPY	./docker-entrypoint.sh /sbin/docker-entrypoint.sh
COPY	./htdocs /var/www/default/htdocs

RUN chmod 0755 /sbin/docker-entrypoint.sh \
	&& rm -rf /etc/lighttpd \
	&& ln -s /config/lighttpd/ /etc/lighttpd \
	&& chown -R lighttpd:lighttpd /var/www/default
	
# Check every 5 minutes if lighttpd responds withing 3 seconds and update
# container health status accordingly. 
# HEALTHCHECK --interval=5m --timeout=3s \
#  CMD curl -f http://localhost/ || exit 1

# Expose http(s) ports
EXPOSE 80 443

VOLUME 	["/usr/local/share/certdata","/config"]
ENTRYPOINT ["/sbin/docker-entrypoint.sh"]
