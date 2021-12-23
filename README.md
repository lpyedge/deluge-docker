## 介绍

Deluge 轻量级 BT PT 客户端


Docker Hub 地址
[https://hub.docker.com/r/lpyedge/deluge](https://hub.docker.com/r/lpyedge/deluge)

### 变量

| 标签  | libtorrent版本 | 备注 ｜
| ------ | ------ | ------ | 
| latest | 1.x | PT适用版本 |
| edge | 2.x | BT使用，好多PT服务器不支持2.x |


### 变量

| 变量名  | 介绍                             |
| ------ | -------------------------------- |
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
