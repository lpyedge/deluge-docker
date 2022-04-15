## 介绍

Deluge 轻量级 BT PT 客户端

[![](https://badgen.net/badge/lpyedge/deluge/blue?icon=docker)](https://hub.docker.com/r/lpyedge/deluge)
[![](https://badgen.net/docker/pulls/lpyedge/deluge?icon=docker&label=pulls)](https://hub.docker.com/r/lpyedge/deluge)
[![](https://badgen.net/docker/stars/lpyedge/deluge?icon=docker&label=stars)](https://hub.docker.com/r/lpyedge/deluge)

[![](https://badgen.net/badge/lpyedge/deluge-docker/purple?icon=github)](https://github.com/lpyedge/deluge-docker)
[![](https://badgen.net/github/license/lpyedge/deluge-docker?color=grey)](https://github.com/lpyedge/deluge-docker/blob/main/LICENSE)


### 标签

| 标签 | libtorrent版本 | 备注 | 镜像大小 |
|-|-|-|-|
| latest | 1.x | PT适用版本 | ![](https://badgen.net/docker/size/lpyedge/deluge/latest?icon=docker&label=size) |
| edge | 2.x | BT使用，好多PT服务器不支持2.x | ![](https://badgen.net/docker/size/lpyedge/deluge/edge?icon=docker&label=size) |


### 变量

| 变量名  | 介绍                             |
| - | - |
| -p 8112 | web访问端口 |
| -p 58946 | BT通信端口 |
| -p 58946/udp | BT通信端口 |
| -e PUID=1000 | 用户ID |
| -e PUID=1000 | 分组ID |
| -e TZ=Asia/Shanghai | 时区 |
| -v /config | 配置数据目录 |
| -v /data | 文件下载目录 |


### 运行

```
docker run -d \
  --name=deluge \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -p 8112:8112 \
  -p 58946:58946 \
  -p 58946:58946/udp \
  -v /x-drivers/config:/config \
  -v /x-drivers/data:/data \
  --restart unless-stopped \
  lpyedge/deluge:latest
```
