#! /bin/sh
mkdir -p /config/log
chown -R $PUID:$PGID /config

GROUPNAME=$(getent group $PGID | cut -d: -f1)
USERNAME=$(getent passwd $PUID | cut -d: -f1)

if [ ! $GROUPNAME ]
then
        addgroup -g $PGID deluge
        GROUPNAME=deluge
fi

if [ ! $USERNAME ]
then
        adduser -G $GROUPNAME -u $PUID -D deluge
        USERNAME=deluge
fi

su $USERNAME -c 'deluged -c /config -l /config/log/deluged.log -L error'
su $USERNAME -c 'deluge-web -d -c /config -l /config/log/deluge-web.log -L error'
