EDS_D=shibboleth-embedded-ds-1.1.0
EDS_F=${EDS_D}.tar.gz
curl -JOLs http://shibboleth.net/downloads/embedded-discovery-service/latest/${EDS_F}
tar -xzvf ${EDS_F}
cd ${EDS_D}
EDS_DEST=/var/www/vhosts/sp.example.org/DS/WAYF
sudo mkdir -p ${EDS_DEST}
sudo cp blank.gif index.html idpselect.css idpselect.js idpselect_config.js ${EDS_DEST}
cd /etc/shibboleth && patch -p1 < /vagrant/sp/patches/eds-etc-shibboleth.patch
service shibd restart
service apache2 restart

