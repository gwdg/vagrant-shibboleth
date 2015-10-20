sudo apt-get install -y apache2
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enmod proxy_ajp
sudo a2enmod socache_shmcb
sudo service apache2 restart

IP=172.16.80.5
HOST=idp3
SCOPE=example.org

sudo tee /etc/apache2/sites-available/idp3.example.org.conf <<EOF
################################################
#
# Bitte im Folgenden 'IDP-IP-ADRESSE' und ggf. 'IDP-IPv6-ADRESSE'
# jeweils durch die entsprechende IP und 'idp.uni-beispiel.de' durch 
# den FQDN Ihres IdPs ersetzen!
#
# Die Angabe der Portnummer bei 'ServerName' ist wichtig falls
# für den SSO auf Port 443 ein anderes Zertifikat verwendet werden
# soll als für die Attribute Authority auf Port 8443
#
#
# SingleSignOnService
#
# https://idp.uni-beispiel.de/idp/profile/SAML2/POST/SSO
# https://idp.uni-beispiel.de/idp/profile/SAML2/Redirect/SSO
# https://idp.uni-beispiel.de/idp/profile/Shibboleth/SSO
#
# Sofern der Port 443 nicht von der Distribution angeschaltet wird
# (bei Debian in /etc/apache2/ports.conf, bei openSUSE in /etc/apache2/listen.conf)
# können Sie das hier manuell machen:
#
# Listen 443
#
SSLStaplingCache shmcb:/tmp/stapling_cache(102400)
 
#<VirtualHost ${IP}:80>
#  ServerName    ${HOST}.${SCOPE}
#  RedirectMatch permanent ^/(.*)$ https://${HOST}.${SCOPE}/$1
#</VirtualHost>
 
################################################
#
# SingleSignOnService auf Port 443
#
<VirtualHost ${IP}:443>
  ServerName              ${HOST}.${SCOPE}
 
  Header add Strict-Transport-Security "max-age=15768000"
 
  SSLEngine on
  SSLCertificateFile      /etc/ssl/localcerts/${HOST}.${SCOPE}.crt.pem
  SSLCertificateKeyFile   /etc/ssl/private/${HOST}.${SCOPE}.key.pem
  # SSLCACertificateFile    /etc/ssl/chains/${SCOPE}-chain.pem
 
  AddDefaultCharset UTF-8
 
  SSLEngine on
  SSLProtocol All -SSLv2 -SSLv3
  SSLHonorCipherOrder On
  SSLCipherSuite 'ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:ECDH+3DES:DH+3DES:RSA+3DES:!aNULL:!eNULL:!LOW:!RC4:!MD5:!EXP:!PSK:!DSS:!SEED:!ECDSA:!CAMELLIA'
 
  SSLUseStapling on
  SSLStaplingReturnResponderErrors off
 
  <Location /idp>
    Require all granted
    ProxyPass ajp://localhost:8009/idp
    Header always append X-FRAME-OPTIONS "DENY"
  </Location>
 
</VirtualHost>
 
################################################
#
# ArtifactResolutionService und AttributeService
#
# https://idp.beispiel-uni.de:8443/idp/profile/SAML2/SOAP/ArtifactResolution
# https://idp.beispiel-uni.de:8443/idp/profile/SAML1/SOAP/ArtifactResolution
#
# https://idp.beispiel-uni.de:8443/idp/profile/SAML2/SOAP/AttributeQuery
# https://idp.beispiel-uni.de:8443/idp/profile/SAML1/SOAP/AttributeQuery
#
Listen ${IP}:8443
 
<VirtualHost ${IP}:8443>
  ServerName              ${HOST}.${SCOPE}
 
  Header add Strict-Transport-Security "max-age=15768000"
 
  SSLEngine on
  SSLCertificateFile      /etc/ssl/localcerts/${HOST}.${SCOPE}.crt.pem
  SSLCertificateKeyFile   /etc/ssl/private/${HOST}.${SCOPE}.key.pem
  # SSLCACertificateFile    /etc/ssl/chains/${SCOPE}-chain.pem
  SSLCACertificatePath    /etc/ssl/certs
 
  SSLProtocol All -SSLv2 -SSLv3
  SSLHonorCipherOrder On
  SSLCipherSuite 'ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:ECDH+3DES:DH+3DES:RSA+3DES:!aNULL:!eNULL:!LOW:!RC4:!MD5:!EXP:!PSK:!DSS:!SEED:!ECDSA:!CAMELLIA'
 
  SSLVerifyClient       optional_no_ca
  SSLVerifyDepth        10
  SSLOptions            +StdEnvVars +ExportCertData
 
  SSLUseStapling on
  SSLStaplingReturnResponderErrors off
 
  <Location /idp>
    Require all granted
    ProxyPass ajp://localhost:8009/idp
  </Location>
 
</VirtualHost>
EOF

sudo mkdir /etc/ssl/localcerts

sudo openssl req -batch -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/ssl/private/${HOST}.${SCOPE}.key.pem \
     -out /etc/ssl/localcerts/${HOST}.${SCOPE}.crt.pem \
     -subj /CN=${HOST}.${SCOPE} 2>/dev/null

sudo chmod 640 /etc/ssl/private/${HOST}.${SCOPE}.key.pem
sudo chown root:ssl-cert /etc/ssl/private/${HOST}.${SCOPE}.key.pem

sudo a2ensite idp3.example.org
sudo service apache2 reload

