# FreeSwitch 的容器镜像

本仓库是一个基于 ubuntu:22.04 镜像，从源码开始构建 FreeSwitch 的容器镜像的脚本

## 相关说明

- freeswitch: 目录存放的是 freesswitch[1.10.11](https://files.freeswitch.org/releases/freeswitch/freeswitch-1.10.11.-release.zip)版本的源码
- libks: 目录存放的是 libks[1.8.2](https://github.com/signalwire/libks/archive/refs/tags/v1.8.2.zip)版本的源码
- signalwire-c: 目录存放的是 signalwire-c[1.3.0](https://github.com/signalwire/signalwire-c/archive/refs/tags/1.3.0.tar.gz)版本的源码
- sofia-sip: 目录存放的是 sofia-sip[1.13.17](https://github.com/freeswitch/sofia-sip/archive/refs/tags/v1.13.17.tar.gz)版本的源码
- spandsp: 目录存放的是 spandsp[源码的 master 分支](https://github.com/freeswitch/spandsp.git)版本的源码
  > 特别说明：
  >
  > - spandsp 需要使用 commit id：0d2e6ac65e0e8f53d652665a743015a88bf048d4 的提交
- fsw-conf: 目录中是 freeswitch 的默认配置文件，运行容器可以将此目录挂到容器中的 _/usr/local/etc/freeswitch_ 目录，它是 freeswitch 读取的配置文件目录。

## 构建示例

> docker build -t freeswitch:1.10.11 .

## 运行示例

> docker run --name freeswitch -p 5060:5060/udp -v ./fsw-conf:/usr/local/etc/freeswitch freeswitch:1.10.11
