FROM alpine:3.20 as stage

ARG VERSION

RUN apk add --no-cache \
    curl \
    xz
RUN mkdir -p /opt/mylar3
RUN curl -o /tmp/mylar3.tar.gz -sL "https://github.com/mylar3/mylar3/archive/v${VERSION}.tar.gz"
RUN tar xzf /tmp/mylar3.tar.gz -C /opt/mylar3 --strip-components=1
RUN rm -rf /tmp/*

FROM python:3.12.6-alpine

COPY --from=stage /opt/mylar3 /opt/mylar3/

RUN apk add --no-cache \
      jpeg \
      libwebp-tools \
      nodejs \
      tzdata \
      zlib \
  && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main \
      unrar \
  && pip install --no-cache-dir \
      pyOpenSSL \
  && pip install --no-cache-dir -r \
      /opt/mylar3/requirements.txt

EXPOSE 8090
VOLUME [ "/data" ]
ENV HOME /data
WORKDIR $HOME
CMD [ "/usr/local/bin/python", "/opt/mylar3/Mylar.py", "--datadir=/data", "--config=/data/mylar.ini", "--nolaunch" ]

LABEL org.opencontainers.image.description="The python3 version of the automated Comic Book downloader (cbr/cbz) for use with various download clients."
LABEL org.opencontainers.image.licenses="GPL-3.0-only"
LABEL org.opencontainers.image.source="https://github.com/mylar3/mylar3"
LABEL org.opencontainers.image.title="mylar3"
LABEL org.opencontainers.image.version=${VERSION}