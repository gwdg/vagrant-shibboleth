#!/bin/sh
apt-get update
apt-get install -y ntpdate
echo "Europe/Berlin" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
ntpdate-debian
sed -i '/127.0.1.1/d' /etc/hosts

