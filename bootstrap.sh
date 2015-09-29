#!/bin/sh

vagrant plugin install vagrant-hostmanager

case `uname` in
  Darwin)
    sudo tee -a /etc/sudoers <<EOF
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp $HOME/.vagrant.d/tmp/hosts.local /etc/hosts
%admin ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE
EOF
    ;;
  Linux)
    if [ -f /etc/debian_version ]; then
      sudo apt-get install -y unzip curl
    fi
    sudo tee -a /etc/sudoers <<EOF
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp $HOME/.vagrant.d/tmp/hosts.local /etc/hosts
%admin ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE
EOF
    ;;
  CYGWIN*)
    sudo apt-get install -y unzip curl
    ;;
esac
  
cd idp
./bootstrap.sh 
cd ..

