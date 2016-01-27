r=/vagrant/sp
. $r/common
mkdir -p ${EDS_DEST}
cd $r/_work/${EDS_D}
cp blank.gif index.html idpselect.css idpselect.js idpselect_config.js ${EDS_DEST}
cd ${EDS_DEST}
patch -p1 < $r/eds.patch

