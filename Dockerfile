# FROM alpine:3
FROM emmercm/libtorrent:1-alpine

#维护者信息
LABEL name="lpyedge/deluge"
LABEL url="https://hub.docker.com/r/lpyedge/deluge"
LABEL email="lpyedge#163.com"

ENV USER=deluge \
    PUID=1000 \
    PGID=1000

# RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
# RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
# RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories;

# ARG VERSION=1.2.[0-9]\\+

# SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# RUN apk --update add --no-cache                              boost-python3 boost-system libgcc libstdc++ openssl python3 && \
#     apk --update add --no-cache --virtual build-dependencies boost-build boost-dev cmake coreutils g++ gcc git jq py3-setuptools python3-dev openssl-dev samurai && \
#     # Checkout from source
#     cd "$(mktemp -d)" && \
#     git clone --branch "$( \ 
#         wget -qO - https://api.github.com/repos/arvidn/libtorrent/tags?per_page=100 | jq -r '.[].name' | \
#         awk '{print $1" "$1}' | \
#         # Get rid of prefixes
#         sed 's/^libtorrent[^0-9]//i' | \
#         sed 's/^v//i' | \
#         # Use periods for major.minor.patch
#         sed 's/[^a-zA-Z0-9.]\([0-9]\+.* .*\)/.\1/g' | \
#         sed 's/[^a-zA-Z0-9.]\([0-9]\+.* .*\)/.\1/g' | \
#         # Make sure patch version exists
#         sed 's/^\([0-9]\+\.[0-9]\+\)\([^0-9.].\+\)/\1.0\2/' | \
#         # Get the right version
#         sort --version-sort --key=1,1 | \
#         grep "${VERSION}" | \
#         tail -1 | \
#         awk '{print $2}' \
#     )" --depth 1 https://github.com/arvidn/libtorrent.git && \
#     cd libtorrent && \
#     git clean --force && \
#     git submodule update --depth=1 --init --recursive && \
#     # Run b2
#     PREFIX=/usr && \
#     BUILD_CONFIG="release cxxstd=14 crypto=openssl warnings=off address-model=32 -j$(nproc)" && \
#     BOOST_ROOT="" b2 ${BUILD_CONFIG} link=shared install --prefix=${PREFIX} && \
#     BOOST_ROOT="" b2 ${BUILD_CONFIG} link=static install --prefix=${PREFIX} && \
#     cd bindings/python && \
#     PYTHON_MAJOR_MINOR="$(python3 --version 2>&1 | sed 's/\(python \)\?\([0-9]\+\.[0-9]\+\)\(\.[0-9]\+\)\?/\2/i')" && \
#     echo "using python : ${PYTHON_MAJOR_MINOR} : $(command -v python3) : /usr/include/python${PYTHON_MAJOR_MINOR} : /usr/lib/python${PYTHON_MAJOR_MINOR} ;" > ~/user-config.jam && \
#     BOOST_ROOT="" b2 ${BUILD_CONFIG} install_module python-install-scope=system && \
#     # Remove temp files
#     cd && \
#     apk del --purge build-dependencies && \
#     rm -rf /tmp/*

#custom config scripts
RUN mkdir /config
COPY scripts/core.conf /config/core.conf
COPY scripts/start.sh /
COPY scripts/health.sh /

#设置权限
RUN chmod -R 777 /start.sh /health.sh /config

ENV PYTHON_EGG_CACHE=/config/.cache

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --virtual=base --upgrade \
      bash \
      #p7zip \
      #unrar \
      unzip \
      tzdata \
      ca-certificates \
      curl \
      libtorrent-rasterbar && \
      
    apk add --no-cache --virtual=build-dependencies --upgrade \
      build-base \
      libffi-dev \
      zlib-dev \
      openssl-dev \
      libjpeg-turbo-dev \
      linux-headers \
      musl-dev \
      cargo \
      git \
      python3-dev && \

    python3 -m ensurepip --upgrade && \

    pip3 --timeout 40 --retries 10  install --no-cache-dir --upgrade  \
      wheel \
      pip \
      lbry-libtorrent \
      six==1.16.0 && \
      
    #Checkout deluge source    
    git clone --branch master --single-branch --depth 1 https://github.com/deluge-torrent/deluge /tmp/deluge && \
    cd /tmp/deluge && \    
    git clean --force && \
    git submodule update --depth=1 --init --recursive && \
    
    # build & install deluge
    pip3 --timeout 40 --retries 10 install --no-cache-dir --upgrade --requirement requirements.txt && \
    python3 setup.py clean -a && \
    python3 setup.py build && \
    python3 setup.py install && \
    
    # clean build depend & source
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

# expose port for http
EXPOSE 8112/tcp

# expose port for deluge daemon
#EXPOSE 58846

# expose port for incoming torrent data (tcp and udp)
EXPOSE 58946/tcp 58946/udp


VOLUME ["/config","/data"]

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
  CMD /health.sh 58846 8112

WORKDIR /config

ENTRYPOINT ["/start.sh"]
