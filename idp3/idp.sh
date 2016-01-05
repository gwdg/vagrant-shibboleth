r=/vagrant/idp3

cd $r
. ./config

SRC=$r/_work/$N

cd ${SRC}

MERGE_PROPERTIES=merge.properties
tee $MERGE_PROPERTIES <<EOF
idp.entityID=https://idp3.example.org/shibboleth
idp.sealer.storePassword=secret
idp.sealer.keyPassword=secret
idp.scope=example.org
EOF
 
# -Didp.uri.subject.alt.name="DNS:${HOST}.${SCOPE}" \
# -Didp.sealer.alias=sealer \

sudo JAVA_HOME=/usr ./bin/install.sh \
  -noinput \
  -Didp.home=${DEST} \
  -Didp.src.dir=${SRC} \
  -Didp.target.dir=${DEST} \
  -Didp.home.input=${DEST} \
  -Didp.host.name=${HOST}.${SCOPE} \
  -Didp.keystore.pass=none \
  -Didp.scope=${SCOPE} \
  -Didp.merge.properties=${MERGE_PROPERTIES} \
  -Didp.sealer.password=secret \
  -Didp.keystore.password=secret \
  -Dinstall.config=yes

cd ${DEST}/bin
sudo JAVA_HOME=/usr ./build.sh -Didp.target.dir=${DEST}

cd ${DEST}/conf
sudo patch -p1 < $r/idp-conf.patch
cd ${DEST}
#sudo patch -p0 < $r/attributes.patch
#sudo patch -p0 < $r/tou.patch
#sudo patch -p0 < $r/pid.patch


sudo mkdir -p /etc/ssl/aai
sudo wget -q https://www.aai.dfn.de/fileadmin/metadata/dfn-aai.pem -O /etc/ssl/aai/dfn-aai.pem

