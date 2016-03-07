#!/bin/sh
apt-get update
apt-get install -y ntpdate
echo "Europe/Berlin" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
ntpdate-debian

