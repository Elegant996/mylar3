FROM scratch AS source

ARG VERSION

ADD --exclude=\.* https://github.com/mylar3/mylar3.git#v${VERSION} /mylar3

FROM python:3.12.3-alpine AS build-sysroot

ENV PATH="/sysroot/usr/local/opt/python/bin:$PATH"
ENV PIP_ROOT_USER_ACTION=ignore

# Prepare sysroot
RUN mkdir -p /sysroot/etc/apk && cp -r /etc/apk/* /sysroot/etc/apk/

# Fetch build dependencies
RUN apk add --no-cache \
    build-base \
    linux-headers
RUN pip install --upgrade --no-cache-dir \
    pip \
    wheel

# Fetch runtime dependencies
RUN apk add --no-cache --initdb -p /sysroot \
    jpeg-dev \
    libffi-dev \
    libwebp-tools \
    nodejs \
    tzdata \
    zlib-dev

# Install mylar3 to new system root
COPY --from=source /mylar3 /sysroot/opt/mylar3/
RUN mkdir -p /usr/local/opt/python /sysroot/usr/local/opt/python
RUN ln -s /usr/local/opt/python /sysroot/usr/local/opt/python
RUN python3 -m venv /usr/local/opt/python
RUN source /usr/local/opt/python
RUN pip install --no-cache-dir --root=/sysroot --requirement \
    /sysroot/opt/mylar3/requirements.txt \
    pyOpenSSL

# Install entrypoint
COPY --chmod=755 ./entrypoint.sh /sysroot/entrypoint.sh

# Build image
FROM python:3.12.3-alpine
COPY --from=build-sysroot /sysroot/ /

EXPOSE 8090
VOLUME ["/data"]
ENV HOME="/data"
ENV PATH="/usr/local/opt/python/bin:$PATH"
WORKDIR $HOME
CMD ["python", "/opt/mylar3/Mylar.py", "--datadir=/data", "--config=/data/mylar.ini", "--nolaunch"]

ARG VERSION

LABEL org.opencontainers.image.description="The python3 version of the automated Comic Book downloader (cbr/cbz) for use with various download clients."
LABEL org.opencontainers.image.licenses="GPL-3.0-only"
LABEL org.opencontainers.image.source="https://github.com/mylar3/mylar3"
LABEL org.opencontainers.image.title="mylar3"
LABEL org.opencontainers.image.version=${VERSION}
