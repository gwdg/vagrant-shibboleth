r=/vagrant/sp
. $r/common
mkdir -p ${EDS_DEST}
cd $r/_work/${EDS_D}
cp blank.gif index.html idpselect.css idpselect.js idpselect_config.js ${EDS_DEST}

# cd /etc/shibboleth && patch -p1 < /vagrant/sp/patches/eds-etc-shibboleth.patch
#$r/sso.sh eds
# EDS_D=shibboleth-embedded-ds-1.1.0
# EDS_F=${EDS_D}.tar.gz
# curl -JOLs http://shibboleth.net/downloads/embedded-discovery-service/latest/${EDS_F}
