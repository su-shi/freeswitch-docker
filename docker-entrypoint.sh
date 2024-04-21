#!/bin/bash
set -e

# Source docker-entrypoint.sh:
# https://github.com/docker-library/postgres/blob/master/9.4/docker-entrypoint.sh
# https://github.com/kovalyshyn/docker-freeswitch/blob/vanilla/docker-entrypoint.sh

if [ "$1" = 'freeswitch' ]; then

    if [ ! -f "/usr/local/etc/freeswitch/freeswitch.xml" ]; then
        mkdir -p /usr/local/etc/freeswitch
        cp -varf /usr/local/share/freeswitch/conf/vanilla/* /usr/local/etc/freeswitch/
    fi

    # mkdir -p /usr/local/var/run/freeswitch
    # mkdir -p /usr/local/var/lib/freeswitch
    # mkdir -p /usr/local/var/log/freeswitch
    
    # chown -R freeswitch:freeswitch /usr/local/share/freeswitch
    # chown -R freeswitch:freeswitch /usr/local/etc/freeswitch
    # chown -R freeswitch:freeswitch /usr/local/var/{run,lib,log}/freeswitch
    
    if [ -d /docker-entrypoint.d ]; then
        for f in /docker-entrypoint.d/*.sh; do
            [ -f "$f" ] && . "$f"
        done
    fi
    
    exec /usr/local/bin/freeswitch -nonat -c
    # exec gosu freeswitch /usr/local/bin/freeswitch -u freeswitch -g freeswitch -nonat -c
fi

exec "$@"
