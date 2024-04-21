FROM ubuntu:22.04 AS build

# 更换源
ADD sources.list /etc/apt/

# 更新
RUN apt update -y && apt install -y  python2 wget curl cmake make pkg-config build-essential autoconf automake yasm libtool libtool-bin uuid-dev libssl-dev libtiff-dev libopus-dev unixodbc-dev libvpx-dev ncurses-dev zlib1g-dev libjpeg-dev libsqlite3-dev libavformat-dev libpng16-16 libtpl-dev libgumbo-dev libcurl4-openssl-dev libpcre3-dev libspeex-dev libspeexdsp-dev libswscale-dev libedit-dev libldns-dev libpq-dev liblua5.1-0-dev libsndfile1-dev
# 编译libks
COPY ./libks /sources/libks
WORKDIR /sources/libks
RUN mkdir build
RUN cp copyright build/copyright
RUN cd build && cmake .. && make && make install

# 编译sofia-sip
COPY ./sofia-sip /sources/sofia-sip
WORKDIR /sources/sofia-sip
RUN ./bootstrap.sh
RUN ./configure
RUN make && make install

# 编译spandsp
COPY ./spandsp /sources/spandsp
WORKDIR /sources/spandsp
RUN ./bootstrap.sh
RUN ./configure
RUN make && make install
RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}
RUN echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}" >> /etc/profile
RUN ldconfig

# 编译signalwire-c
COPY ./signalwire-c /sources/signalwire-c
WORKDIR /sources/signalwire-c
RUN mkdir build
RUN cp ./copyright build/copyright
RUN cd build && cmake .. && make && make install

# 编译freeswitch
COPY ./freeswitch /sources/freeswitch
WORKDIR /sources/freeswitch
RUN ./rebootstrap.sh
RUN ./configure --enable-portable-binary --prefix=/usr/local --with-gnu-ld --with-python2=/usr/bin/python2 --with-openssl --enable-core-odbc-support --enable-zrtp
RUN make && make install
RUN mkdir -p /usr/local/share/freeswitch/conf/
RUN cp -r conf/vanilla /usr/local/share/freeswitch/conf/

# 制作发行镜像
FROM ubuntu:22.04

# 更换源
ADD sources.list /etc/apt/

# 创建运行用户
RUN groupadd -r freeswitch --gid=999 && useradd -r -g freeswitch --uid=999 freeswitch

# 安装依赖
RUN apt-get update -qq 
RUN apt-get install -y --no-install-recommends ca-certificates gnupg2 gosu locales wget curl libgumbo1 libspeex1 libspeexdsp1 libedit2 libtpl0 unixodbc libtiff5 libjpeg62 libavformat58 libswscale5 libldns3 liblua5.1-0 libopus0 libpq5 libsndfile1
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG zh_CN.utf8

COPY docker-entrypoint.sh /
COPY --from=build /lib/libks.so /lib/libks.so
COPY --from=build /usr/local/ /usr/local/

EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 5066/tcp
EXPOSE 7443/tcp
EXPOSE 8081/tcp 8082/tcp
EXPOSE 64535-65535/udp
EXPOSE 16384-32768/udp

## Freeswitch Configuration
VOLUME ["/usr/local/etc/freeswitch"]
## Tmp so we can get core dumps out
VOLUME ["/tmp"]

# Limits Configuration
COPY freeswitch.limits.conf /etc/security/limits.d/

RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}
RUN echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}" >> /etc/profile
RUN ldconfig

# Healthcheck to make sure the service is running
SHELL ["/bin/bash", "-c"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  fs_cli -x status | grep -q ^UP || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch"]