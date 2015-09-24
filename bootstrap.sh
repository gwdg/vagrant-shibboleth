case `uname` in
  Linux)
    if [ -f /etc/debian_version ]; then
      sudo apt-get install -y unzip curl
    fi
    ;;
esac
  
vagrant plugin install vagrant-hostmanager
sudo tee -a /etc/sudoers <<EOF
Cmnd_Alias VAGRANT_HOSTMANAGER_UPDATE = /bin/cp $HOME/.vagrant.d/tmp/hosts.local /etc/hosts
%admin ALL=(root) NOPASSWD: VAGRANT_HOSTMANAGER_UPDATE
EOF
cd idp
./bootstrap.sh 
cd ..

