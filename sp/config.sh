r=/vagrant/sp

openssl req -batch -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/ssl/private/sp.example.org.key \
     -out /etc/ssl/certs/sp.example.org.crt \
     -subj /CN=sp.example.org 2>/dev/null

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/shibboleth/sp-key.pem \
     -out /etc/shibboleth/sp-cert.pem \
     -subj /CN=sp.example.org 2>/dev/null

mkdir -p /var/www/vhosts/sp.example.org

cp $r/apache.conf /etc/apache2/sites-available/sp.conf

cp /etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml.orig

xmlstarlet ed -L \
  -i "//_:Sessions" -t attr -n consistentAddress -v true \
  -u "//_:Sessions/@handlerSSL" -v "true" \
  -u "//_:Sessions/@cookieProps" -v "https" \
  -u "//_:Handler[@type='Status']/@acl" -v "127.0.0.1 ::1 172.16.80.1" \
  -u "//_:Handler[@type='Session']/@showAttributeValues" -v "true" \
  -u "//_:Errors/@supportContact" -v "aai-hotline@example.org" \
  -u "//_:Errors/@helpLocation"   -v "https://sp.example.org/contact/" \
  -u "//_:Errors/@logoLocation"   -v "/shibboleth-sp/logo.jpg" \
  /etc/shibboleth/shibboleth2.xml 

a2enmod ssl
a2ensite sp

service shibd restart
service apache2 reload

#cd $r/patches
#patch /etc/shibboleth/shibboleth2.xml <session.patch
#patch /etc/shibboleth/shibboleth2.xml <status.patch
#patch /etc/shibboleth/shibboleth2.xml <metadata.patch

