# syntax=docker/dockerfile:1
ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}/alpine:latest

#维护者信息
MAINTAINER "lpyedge"
LABEL name="lpyedge/deluge"
LABEL url="https://github.com/lpyedge/deluge"
LABEL email="lpyedge#163.com"

ENV PUID=0
ENV PGID=0

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories;
RUN apk -U --no-cache upgrade
RUN apk add --no-cache ca-certificates
#RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
#RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
#RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add --update --no-cache deluge py3-pip tzdata
RUN pip install setuptools
RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

#ready for start
COPY scripts/start.sh /
RUN mkdir /config
RUN chmod -R 777 /start.sh /config

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
COPY /scripts/core.conf /config/core.conf

ENTRYPOINT ["/start.sh"]
