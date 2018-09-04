FROM alpine:3.7

ARG POSTGRES_VERSION=latest
ENV POSTGRES_VERSION=$POSTGRES_VERSION

RUN apk upgrade --update && \
    apk add \
      bash \
      tzdata \
      vim \
      tini \
      su-exec \
      gzip \
      tar \
      wget \
      gpgme \
      curl && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    if  [ "${POSTGRES_VERSION}" = "latest" ]; \
      then apk add postgresql ; \
      else apk add "postgresql=${POSTGRES_VERSION}" ; \
    fi && \
    # Install gosu
    curl -fsSL https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 -o /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu && \
    # Remove obsolete packages
    apk del \
      curl \
      gpgme && \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql/data

COPY docker-entrypoint.sh /

VOLUME ["/var/lib/postgresql"]
EXPOSE 5432
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
