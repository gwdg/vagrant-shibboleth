#!/bin/sh
r=/vagrant/idp
. $r/common

apt-get install -y apache2 tomcat7 tomcat7-admin 

export DEBIAN_FRONTEND=noninteractive
apt-get install -y -q mysql-server libmysql-java

# sudo apt-get install -y unzip


adduser tomcat7 ssl-cert

# enable ajp and tomcat user
cd /etc && patch -p1 < $r/patches/etc.patch

a2enmod ssl
a2enmod proxy_ajp
a2enmod headers


mysql -u root <<EOF
CREATE USER 'shibboleth'@'localhost' IDENTIFIED by 's3cret';
CREATE DATABASE shibpid_db;
USE shibpid_db;
CREATE TABLE shibpid (
    localEntity VARCHAR(255) NOT NULL,
    peerEntity VARCHAR(255) NOT NULL,
    principalName VARCHAR(255) NOT NULL,
    localId VARCHAR(255) NOT NULL,
    persistentId VARCHAR(255) NOT NULL,
    peerProvidedId VARCHAR(255) NULL,
    creationDate TIMESTAMP NOT NULL,
    deactivationDate TIMESTAMP NULL);
GRANT ALL PRIVILEGES ON shibpid_db.* TO 'shibboleth'@'localhost';
FLUSH PRIVILEGES;
CREATE DATABASE uApprove;
use uApprove;
source ${UAPPROVE_INSTALL}/manual/storage/terms-of-use-schema.sql;
source ${UAPPROVE_INSTALL}/manual/storage/attribute-release-schema.sql;
GRANT ALL PRIVILEGES ON uApprove.* TO 'shibboleth'@'localhost';
FLUSH PRIVILEGES;
EOF

X=`which java`
JAVA_HOME=`readlink -f $X | sed "s:bin/java::"`
export JAVA_HOME

WEBAPP_DIR=$r/webapp

( cd ${IDP_INSTALL} && sudo JAVA_HOME="${JAVA_HOME}" ./install.sh \
  -noinput \
  -Dwebapp.dir=${WEBAPP_DIR} \
  -Didp.home.input=${DEST} \
  -Didp.hostname.input=${HOST}.${SCOPE} \
  -Didp.keystore.pass=none \
  -Didp.scope=${SCOPE} \
  -Dinstall.config=yes
)

chown tomcat7:tomcat7 ${DEST}/metadata ${DEST}/logs 

# cp -Rf $r/credentials/* ${DEST}/credentials
chmod 440 ${DEST}/credentials/*.key
chmod 444 ${DEST}/credentials/*.crt
chown root:ssl-cert ${DEST}/credentials/*

cp -Rf $r/conf/* ${DEST}/conf
chmod 640 ${DEST}/conf/*

chown root:tomcat7 ${DEST}/conf/*

cd /etc
patch -p2 <$r/patches/etc-tomcat7-catalina.patch
patch -p2 <$r/patches/etc-default-tomcat7.patch
#cp $r/etc/tomcat7/catalina.properties /etc/tomcat7
#cp $r/etc/default/tomcat7             /etc/default

mkdir -p ${DEST}/etc
tee ${DEST}/etc/tomcat.xml <<EOF
<Context docBase="${DEST}/war/idp.war"
         privileged="true"
         antiResourceLocking="false"
         antiJARLocking="false"
         unpackWAR="false"
         swallowOutput="true">
  <Realm className="org.apache.catalina.realm.JAASRealm"
         appName="ShibUserPassAuth"
         userClassNames="edu.vt.middleware.ldap.jaas.LdapPrincipal"
         roleClassNames="edu.vt.middleware.ldap.jaas.LdapRole"/>
</Context>
EOF
ln -s ${DEST}/etc/tomcat.xml /etc/tomcat7/Catalina/localhost/idp.xml

tee ${DEST}/etc/apache2.conf <<EOF
<VirtualHost ${IP}:443>
  ServerName ${HOST}.${SCOPE}
  SSLEngine on
  SSLCertificateFile ${DEST}/credentials/idp.crt
  SSLCertificateKeyFile ${DEST}/credentials/idp.key
  # SSLCertificateChainFile ${DEST}/credentials/ca-chain.crt
  SSLProtocol All -SSLv2 -SSLv3
  SSLHonorCipherOrder On
  SSLCipherSuite 'ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:ECDH+3DES:DH+3DES:RSA+3DES:!aNULL:!eNULL:!LOW:!RC4:!MD5:!EXP:!PSK:!DSS:!SEED:!ECDSA:!CAMELLIA'
  <Location /idp>
    Allow from all
    ProxyPass ajp://localhost:8009/idp
    Header always append X-FRAME-OPTIONS "DENY"
  </Location>
</VirtualHost>
Listen 8443
<VirtualHost ${IP}:8443>
  ServerName ${HOST}.${SCOPE}
  SSLEngine on
  SSLCertificateFile ${DEST}/credentials/idp.crt
  SSLCertificateKeyFile ${DEST}/credentials/idp.key
  # SSLCertificateChainFile ${DEST}/credentials/ca-chain.crt
  SSLProtocol All -SSLv2 -SSLv3
  SSLHonorCipherOrder On
  SSLCipherSuite 'ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:ECDH+3DES:DH+3DES:RSA+3DES:!aNULL:!eNULL:!LOW:!RC4:!MD5:!EXP:!PSK:!DSS:!SEED:!ECDSA:!CAMELLIA'
  SSLVerifyClient optional_no_ca
  SSLVerifyDepth  10
  SSLOptions      +StdEnvVars +ExportCertData
  <Location /idp>
    Allow from all
    ProxyPass ajp://localhost:8009/idp
    Header always append X-FRAME-OPTIONS "DENY"
  </Location>
</VirtualHost>
EOF
ln -s ${DEST}/etc/apache2.conf /etc/apache2/sites-available/idp.conf
a2ensite idp

apt-get install -y xmlstarlet

cd /opt/shibboleth-idp/metadata
mv idp-metadata.xml idp-metadata-no-mdui.xml
. $r/mdui.conf
$r/mdui.sh idp-metadata-no-mdui.xml >idp-metadata.xml
mv idp-metadata.xml idp-metadata-no-ecp.xml
$r/mdui2.sh idp-metadata-no-ecp.xml >idp-metadata.xml
cp $r/logo.jpg /var/www/html

service apache2 reload
service tomcat7 restart


