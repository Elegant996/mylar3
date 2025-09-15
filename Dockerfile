# syntax=docker/dockerfile:1.7-labs

FROM python:3.13.7-alpine AS build-sysroot

ARG TAG

ADD "https://github.com/mylar3/mylar3/archive/refs/tags/${TAG}.tar.gz" "/archives/mylar3.tar.gz"
ADD "https://www.rarlab.com/rar/rarlinux-x64-712.tar.gz" "/archives/unrar.tar.gz"

ENV PATH="/sysroot/usr/local/opt/python/bin:$PATH"
ENV PIP_ROOT_USER_ACTION=ignore

# Prepare sysroot
RUN set -ex; \
    mkdir -p /sysroot/opt/mylar3; \
    mkdir -p /sysroot/etc/apk; \
    cp -r /etc/apk/* /sysroot/etc/apk/

# Fetch build dependencies
RUN set -ex; \
    apk add --no-cache \
    build-base \
    libffi-dev \
    linux-headers \
    tar \
    ; \
    pip install --upgrade --no-cache-dir \
    pip \
    wheel

# Fetch runtime dependencies
RUN apk add --no-cache --initdb -p /sysroot \
    dumb-init \
    jpeg-dev \
    libffi-dev \
    libwebp-tools \
    nodejs \
    tzdata \
    tini \
    zlib-dev \
    ; \
    tar -xvzf "/archives/unrar.tar.gz" -C "/sysroot/usr/bin" --strip-components=1 --no-anchored 'unrar'

# Install mylar3 to new system root
RUN set -ex; \
    tar -xvzf "/archives/mylar3.tar.gz" -C "/sysroot/opt/mylar3" --strip-components=1; \
    mkdir -p /usr/local/opt/python /sysroot/usr/local/opt/python; \
    ln -s /usr/local/opt/python /sysroot/usr/local/opt/python; \
    python3 -m venv /usr/local/opt/python; \
    source /usr/local/opt/python; \
    pip install --no-cache-dir --root=/sysroot --requirement --no-warn-script-location \
    /sysroot/opt/mylar3/requirements.txt \
    pyOpenSSL

# Install entrypoint
COPY --chmod=755 ./entrypoint.sh /sysroot/entrypoint.sh

# Build image
FROM python:3.13.7-alpine
COPY --from=build-sysroot /sysroot/ /

EXPOSE 8090
VOLUME [ "/data" ]
ENV HOME="/data"
ENV PATH="/usr/local/opt/python/bin:${PATH}"
WORKDIR $HOME
ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/entrypoint.sh" ]
CMD [ "python", "/opt/mylar3/Mylar.py", "--daemon", "--nolaunch", "--pidfile=/run/mylar/mylar.pid", "--datadir=/data" ]