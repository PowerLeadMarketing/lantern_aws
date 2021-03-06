#!/usr/bin/env bash

# Configure the machine where this script is run as a Salt
# (http://saltstack.org) master and minion.  By the time you run this, the
# server states should have been uploaded to /srv/salt.

HOSTNAME=cloudmaster

export DEBIAN_FRONTEND=noninteractive

LOG=/tmp/salt-bootstrap.log

# Feel free to comment this out if it causes any problems.  I was getting
# massive warning spam from perl because of a missing locale.
locale-gen en_US en_US.UTF-8 gl_ES.UTF-8
dpkg-reconfigure locales

# We configure the hostname before we generate the salt keys so we get the
# correct configuration to begin with and so we don't have to update salt keys
# later.
echo $HOSTNAME > /etc/hostname
hostname -F /etc/hostname

# 'salt' alias is so the minion will find the local master.
sed -i "s/^127.0.0.1.*$/127.0.0.1 $HOSTNAME localhost salt/" /etc/hosts

apt-get install -y python-software-properties
# This is necessary to get a version of python-zmq linked against libzmq3,
# which in turn is needed for stability of long-term connections.
add-apt-repository -y ppa:saltstack/salt
apt-get update -y > >(tee -a $LOG) 2>&1
#apt-get upgrade -y > >(tee -a $LOG) 2>&1
apt-get install python python-support python-pkg-resources python-crypto python-jinja2 python-m2crypto python-yaml python-zmq dctrl-tools msgpack-python python-markupsafe python-pip debconf-utils -y -o DPkg::Options::=--force-confold > >(tee -a $LOG) 2>&1
apt-get autoremove -y > >(tee -a $LOG) 2>&1
pip install --upgrade pip > >(tee -a $LOG) 2>&1
hash -r

pip install salt==$SALT_VERSION > >(tee -a $LOG) 2>&1
salt-master -d &
salt-minion -d &

while [ ! -e /etc/salt/pki/master/minions_pre/$HOSTNAME ]
do
    echo "Key not preaccepted yet; waiting..." > >(tee -a $LOG) 2>&1
    sleep 1
done

# Make extra sure we are accepting the local key.
rm /etc/salt/pki/master/minions_pre/$HOSTNAME
cp /etc/salt/pki/minion/minion.pub /etc/salt/pki/master/minions/$HOSTNAME

salt-call state.highstate > >(tee -a $LOG) 2>&1

echo "Salt bootstrap done." > >(tee -a $LOG) 2>&1
