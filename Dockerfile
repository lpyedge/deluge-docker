# syntax=docker/dockerfile:1

FROM wiserain/libtorrent:latest-alpine3.15 as final

#维护者信息
LABEL name="lpyedge/deluge"
LABEL url="https://github.com/lpyedge/deluge"
LABEL email="lpyedge#163.com"

ENV PUID=0
ENV PGID=0

# RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
# RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
# RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories;

ENV PYTHON_EGG_CACHE=/config/.cache

RUN apk update && apk upgrade

RUN apk add --no-cache --virtual=base --upgrade \
  bash \
  p7zip \
  #unrar \
  unzip \
  tzdata \
  ca-certificates \
  curl

RUN apk add --no-cache --virtual=build-dependencies --upgrade \
  build-base \
  libffi-dev \
  zlib-dev \
  openssl-dev \
  libjpeg-turbo-dev \
  linux-headers \
  musl-dev \
  cargo \
  git \
  python3-dev

RUN python3 -m ensurepip --upgrade 
RUN git clone git://deluge-torrent.org/deluge.git /source
RUN cd /source/deluge
RUN git checkout -b master
RUN pip3 --timeout 40 --retries 10  install --no-cache-dir --upgrade  \
  wheel \
  pip \
  six==1.16.0

RUN pip3 --timeout 40 --retries 10 install --no-cache-dir --upgrade --requirement requirements.txt && \
  python3 setup.py clean -a && \
  python3 setup.py build && \
  python3 setup.py install && \
  apk del --purge build-dependencies && \
  rm -rf /source/*

# expose port for http
EXPOSE 8112

# expose port for deluge daemon
#EXPOSE 58846

# expose port for incoming torrent data (tcp and udp)
EXPOSE 58946
EXPOSE 58946/udp

WORKDIR /config
VOLUME ["/config"]
VOLUME ["/data"]

#custom config core.conf
COPY scripts/core.conf /config/core.conf
COPY scripts/start.sh /
COPY scripts/healthcheck.sh /

RUN chmod -R 777 /start.sh /healthcheck.sh /config

HEALTHCHECK --interval=5m --timeout=3s --start-period=30s \
  CMD /healthcheck.sh 58846 8112

ENTRYPOINT ["/start.sh"]
