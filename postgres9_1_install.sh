#!/bin/sh

# I’m setting this directory because always exist and is for opt software

OPTDIR="/opt/postgres"

PGREPO="/etc/yum.repos.d/pgdg-91-redhat.repo"

PGMAINREPO="/etc/yum.repos.d/amzn-main.repo"

PGUPDATESREPO="/etc/yum.repos.d/amzn-updates.repo"

VOLUMEDIR="/media/volume"

DBDIR="$VOLUMEDIR/pgsql"

if [ ! -d "$OPTDIR" ]; then

    mkdir /opt/postgres

fi

pushd  /opt/postgres

wget http://yum.pgrpms.org/9.1/redhat/rhel-6-i386/pgdg-redhat91-9.1-5.noarch.rpm

sudo rpm -ivh pgdg-redhat91-9.1-5.noarch.rpm

if [ ! -d "$PGREPO" ]; then

    echo "Postgres 9.1 failed to install - repo not found"

    exit

fi

# Replace $releasever with '6'

sed -i.bak 's/$releasever/6/g' $PGREPO

# Exclude postgres packages from default amazon repos

sed -i.back -e '/\[amzn-main\]/{:a;n;/^$/!ba;i\exclude=postgresql*' -e '}' $PGMAINREPO

sed -i.back -e '/\[amzn-main\]/{:a;n;/^$/!ba;i\exclude=postgresql*' -e '}' $PGUPDATESREPO

yum -y install postgresql91 postgresql91-contrib postgresql91-devel postgresql91-server postgresql-plperl

if [ ! -d "$VOLUMEDIR" ]; then

    echo "You need to mount a volume (min 20G) in /media/volume"

    exit

fi
