ARG ALPINE_IMAGE=alpine:latest

FROM ${ALPINE_IMAGE} as stage

ARG VERSION

RUN apk add --no-cache --virtual=build-dependencies \
      build-base \
      curl \
      jpeg-dev \
      jq \
      libffi-dev \
      libwebp-dev \
      py3-cffi \
      python3-dev \
      zlib-dev \
  && apk add --no-cache \
      jpeg \
      libwebp-tools \
      nodejs \
      py3-openssl \
      py3-pip \
      python3 \
      tzdata \
      zlib \
  && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main \
      unrar \
  && python3 -m venv .venv \
  && pip3 install --no-cache-dir -U \
      pip \
  && mkdir -p /opt/mylar3 \
  && curl -o /tmp/mylar3.tar.gz -L https://github.com/mylar3/mylar3/archive/${VERSION}.tar.gz \
  && tar xf /tmp/mylar3.tar.gz -C /opt/mylar3 --strip-components=1 \
  && pip install --no-cache-dir -r \
      /opt/mylar3/requirements.txt \
  && apk del --purge build-dependencies \
  && rm -rf /tmp/*

EXPOSE 8090
VOLUME [ "/data" ]
ENV HOME /data
WORKDIR $HOME
CMD [ "/usr/bin/python3", "/opt/mylar3/Mylar.py", "--datadir=/data", "--config=/data/mylar.ini", "--nolaunch" ]

LABEL org.opencontainers.image.description="The python3 version of the automated Comic Book downloader (cbr/cbz) for use with various download clients."
LABEL org.opencontainers.image.licenses="GPL-3.0-only"
LABEL org.opencontainers.image.source="https://github.com/mylar3/mylar3"
LABEL org.opencontainers.image.title="mylar3"
LABEL org.opencontainers.image.version="${VERSION}"